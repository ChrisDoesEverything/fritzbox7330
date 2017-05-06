<?lua
g_page_type = "all"
g_page_title = ""
dofile("../templates/global_lua.lua")
require"html"
require"http"
require"general"
require"pushservice"
g_back_to_page = http.get_back_to_page( "/system/push_list.lua" )
g_menu_active_page = g_back_to_page
g_mode = box.post.list or box.get.list
g_explain = ""
if box.post.cancel or not g_mode then
http.redirect(href.get(g_back_to_page))
end
if string.match(box.post.edit or "", "tam(%d+)") then
-- Tam Edit-Btn
http.redirect(href.get("/system/push_edit.lua",
http.url_param("edit", box.post.edit), http.url_param("list", "tam"), http.url_param("back_to_page", box.glob.script)
))
elseif string.match(box.post.edit or "", "smarthome(%d+)") then
-- Smarthome Edit-Btn
http.redirect(href.get("/system/push_edit.lua",
http.url_param("edit", box.post.edit), http.url_param("list", "smarthome"), http.url_param("back_to_page", box.glob.script)
))
end
if g_mode == "tam" then
g_page_title = [[{?951:679?}]]
g_explain = [[{?951:585?}]]
g_page_help = "hilfe_system_pushservice_tamlist.html"
elseif g_mode == "smarthome" then
g_page_title = [[{?951:624?}]]
g_explain = [[{?951:383?}]]
g_page_help = "hilfe_system_pushservice_smarthomelist.html"
else
-- Wir wissen nicht, was wir tun sollen ....
http.redirect(href.get(g_back_to_page))
end
local push = {}
if g_mode == "tam" then
do
local tams = pushservice.tam.list
for i, t in ipairs(tams) do
table.insert(push, {
tam = t,
edit = "tam" .. t.idx,
text = t.name,
enabled = t.pushmail_active == "1" or t.pushmail_active == "2",
mailto = t.MailAddress
})
end
end
elseif g_mode == "smarthome" then
do
local list = pushservice.smarthome.list
for i, dev in ipairs(list) do
table.insert(push, {
edit = "smarthome" .. dev.ID,
text = dev.Name or "",
ain = dev.Identifyer or "",
enabled = dev.pushmailcfg.activ == 1,
mailto = dev.pushmailcfg.email,
pushmailcfg = dev.pushmailcfg
})
end
end
end
if box.post.apply then
local err, msg = 0
if g_mode == "smarthome" then
local enable
for i, p in ipairs(push) do
enable = box.post["enable_" .. p.edit] == p.edit
if enable and not p.enabled then
pushservice.save_default_smarthome(p.pushmailcfg)
elseif not enable and p.enabled then
p.pushmailcfg.activ = 0
aha.SetPushMailConfig(p.pushmailcfg.ID, p.pushmailcfg)
end
end
elseif g_mode == "tam" then
local saveset = {}
local enable, webvar
for i, p in ipairs(push) do
enable = box.post["enable_" .. p.edit] == p.edit
webvar = string.format([[tam:settings/TAM%d]], p.tam.idx)
if enable and not p.enabled then
cmtable.add_var(saveset, webvar .. "/PushmailActive", "1")
if p.tam.MailAddress == "" then
cmtable.add_var(saveset, webvar .. "/MailAddress", pushservice.default_mailto())
end
elseif not enable and p.enabled then
cmtable.add_var(saveset, webvar .. "/PushmailActive", "0")
end
end
err, msg = box.set_config(saveset)
end
if err == 0 then
http.redirect(href.get(g_back_to_page))
end
end
local function edit_btn(p)
if p.edit then
return html.button{
type="submit", class="icon", name="edit", value=p.edit,
html.img{
src="/css/default/images/bearbeiten.gif",
title = [[{?txtIconBtnEdit?}]]
}
}
end
end
local function enable_checkbox(p)
if p.edit then
return html.input{
type='checkbox', name="enable_"..p.edit, id="uiEnable_"..p.edit, value=p.edit, checked=p.enabled
}
end
end
local function enable_label(p)
if p.edit then
return html.label{
['for']="uiEnable_" .. p.edit, p.text
}
else
return p.text
end
end
function write_tam_list()
local tbl = html.table{class="zebra", id="uiPushlist"}
tbl.add(html.tr{
html.th{},
html.th{class="name",
[[{?951:220?}]]
},
html.th{
[[{?951:894?}]]
},
html.th{class="btncolumn"}
})
for i, p in ipairs(push) do
tbl.add(html.tr{
html.td{enable_checkbox(p)},
html.td{class="name", enable_label(p)},
html.td{pushservice.display_mailto(p.mailto)},
html.td{class="btncolumn", edit_btn(p)}
})
end
tbl.write()
end
function write_smarthome_list()
local tbl = html.table{class="zebra", id="uiPushlist"}
tbl.add(html.tr{
html.th{},
html.th{class="name",
[[{?951:76?}]]
},
html.th{
[[{?951:354?}]]
},
html.th{
[[{?951:234?}]]
},
html.th{class="btncolumn"}
})
for i, p in ipairs(push) do
tbl.add(html.tr{
html.td{enable_checkbox(p)},
html.td{class="name", enable_label(p)},
html.td{p.ain},
html.td{pushservice.display_mailto(p.mailto)},
html.td{class="btncolumn", edit_btn(p)}
})
end
tbl.write()
end
function write_list()
if g_mode == "tam" then
write_tam_list()
elseif g_mode == "smarthome" then
write_smarthome_list()
end
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
<script type="text/javascript">
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="list" value="<?lua box.html(g_mode) ?>">
<p>
<?lua box.html(g_explain) ?>
</p>
<hr>
<?lua write_list() ?>
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
