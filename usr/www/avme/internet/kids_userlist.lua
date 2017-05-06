<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_kindersicherung_uebersicht.html"
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"http"
require"href"
require"filter"
require"utf8"
require"cmtable"
g_err = {code=0}
local function goto_edit_page(edit)
local page = "internet/kids_profileedit.lua"
if not filter.editable{UID=edit} then
page = "internet/kids_profileinfo.lua"
end
http.redirect(
href.get(page,
http.url_param("edit", edit),
http.url_param("back_to_page", box.glob.script)
)
)
end
if box.post.edit and box.post.edit ~= "" then
goto_edit_page(box.post.edit)
end
local function get_user_id(user)
user = user or {}
if user.edit then
return user.edit
elseif user.landevice then
return user.landevice
elseif user.autouser then
return user.autouser
elseif user.UID and user.UID ~= "" then
return user.UID
else
return ""
end
end
local function edit_btn(user)
local btn = html.button{type="submit", class="icon", name="edit"}
local profile = filter.get_user_profile(user) or {UID=""}
btn.value = profile.UID or ""
btn.disabled = btn.value == ""
btn.id = string.format([[uiEdit:%s]], get_user_id(user))
btn.add(html.img{
src="/css/default/images/bearbeiten.gif",
title=[[{?txtIconBtnEdit?}]]
})
return btn
end
local function separator_tr(txt, colspan)
return html.tr{class="separator",
html.td{colspan=colspan,
html.hr{}, html.p{html.span{txt}}
}
}
end
local function adjust_zebra_tr(colspan)
return html.tr{style="display:none;", html.td{colspan=colspan}}
end
local function sortno_span()
return html.span{class="sort_no",
html.raw([[&nbsp;]])
}
end
local function profile_select(user)
return filter.profile_select(user, {
style = "width:200px;",
name = string.format([[profile:%s]], get_user_id(user))
})
end
function write_table()
local list = filter.read_userlist()
utf8.sort(list.ip_user, filter.get_displayname)
utf8.sort(list.pc_user, filter.get_displayname)
local colspan = 5
local colgroup = html.colgroup{
html.col{width = "200px"},
html.col{width = "150px"},
html.col{width = "150px"},
html.col{width = "200px"},
html.col{width = "auto"}
}
local tbl = html.table{class="OnlyHead", id="uiList"}
tbl.add(colgroup)
tbl.add(html.tr{class="thead",
html.th{class="sortable name",
[[{?380:413?}]],
sortno_span()
},
html.th{class="sortable",
[[{?380:347?}]],
sortno_span()
},
html.th{class="sortable",
[[{?380:726?}]],
sortno_span()
},
html.th{
[[{?380:598?}]]
},
html.th{class="btncolumn"}
})
local subtbl = html.table{class="zebra_reverse noborder", id="uiDevices"}
subtbl.add(colgroup)
subtbl.add(separator_tr([[{?380:909?}]], colspan))
local u_name, p_name
for i, user in ipairs(list.ip_user) do
u_name = filter.get_displayname(user)
subtbl.add(html.tr{
html.td{class="name", title=u_name, u_name},
html.td{filter.get_allowed(user)},
html.td{class="bar", filter.get_online_time(user)},
html.td{profile_select(user)},
html.td{class="btncolumn", edit_btn(user)}
})
end
u_name = [[{?380:505?}]]
p_name = filter.get_profile_display(list.default_user)
subtbl.add(html.tr{
html.td{class="name", title=u_name, u_name},
html.td{filter.get_allowed(list.default_user)},
html.td{class="bar", filter.get_online_time(list.default_user)},
html.td{title=p_name, p_name},
html.td{class="btncolumn", edit_btn(list.default_user)}
})
if (#list.ip_user % 2) == 1 then
subtbl.add(adjust_zebra_tr(colspan))
end
tbl.add(html.tr{html.td{colspan=colspan,subtbl}})
if #list.pc_user > 0 then
local subtbl = html.table{class="zebra_reverse noborder", id="uiWinUsers"}
subtbl.add(colgroup)
subtbl.add(separator_tr([[{?380:867?}]], colspan))
for i, user in ipairs(list.pc_user) do
u_name = filter.get_displayname(user)
subtbl.add(html.tr{
html.td{class="name", title=u_name, u_name},
html.td{filter.get_allowed(user)},
html.td{class="bar", filter.get_online_time(user)},
html.td{profile_select(user)},
html.td{class="btncolumn", edit_btn(user)}
})
end
if (#list.pc_user % 2) == 0 then
subtbl.add(adjust_zebra_tr(colspan))
end
tbl.add(html.tr{html.td{colspan=colspan, subtbl}})
end
if list.guest_user then
local subtbl = html.table{class="zebra_reverse noborder",id="uiGuests"}
subtbl.add(colgroup)
subtbl.add(separator_tr([[{?380:368?}]], colspan))
u_name = [[{?380:539?}]]
p_name = filter.get_profile_display(list.guest_user)
subtbl.add(html.tr{
html.td{class="name", title=u_name, u_name},
html.td{filter.get_allowed(list.guest_user)},
html.td{class="bar", filter.get_online_time(list.guest_user)},
html.td{title=p_name, p_name},
html.td{class="btncolumn", edit_btn(list.guest_user)}
})
tbl.add(html.tr{html.td{colspan=colspan, subtbl}})
end
tbl.write()
end
function write_explain()
local txt = [[{?380:62?}]]
if not general.is_expert() then
txt = [[{?380:19?}]]
end
html.p{txt}.write()
end
function write_error()
if g_err.code and g_err.code ~= 0 then
require"general"
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
local function read_user(edit)
local standard = filter.get_profile(filter.fixed_profile_uid('standard'))
local data = {}
if edit then
if string.find(edit, "^user[%d]+$") then
data.webvar = string.format("user:settings/user[%s]", edit)
data.name = box.query(data.webvar .. "/name")
data.filter_profile_UID = box.query(data.webvar .. "/filter_profile_UID")
data.type = box.query(data.webvar .. "/type")
data.profile = filter.get_profile(data.filter_profile_UID)
if not data.profile then
data.profile = {UID=""}
end
elseif string.find(edit, "^landevice[%d]+$") then
data.landevice = edit
data.webvar = string.format("landevice:settings/landevice[%s]", edit)
data.name = box.query(data.webvar .. "/ip")
data.type = filter.user_type_value('ip_user')
data.profile = standard
elseif string.find(edit, "^autouser[%d]+$") then
data.autouser = edit
data.webvar = string.format("autouser:status/%s", edit)
data.name = box.query(data.webvar .. "/name")
data.type = box.query(data.webvar .. "/type")
data.profile = {UID=""}
end
end
return data
end
if box.post.apply then
local saveset = {}
local delset = {}
local user, edit, profile_uid
local savelist = {}
for i, name in ipairs(general.sorted_by_i(box.post)) do
if name:find("^profile:") then
profile_uid = box.post[name]
edit = name:gsub("^profile:", "")
user = read_user(edit)
if user then
table.insert(savelist, {user=user, profile_uid=profile_uid})
end
end
end
filter.save_profiles(saveset, delset, savelist)
if #saveset > 0 then
g_err.code, g_err.msg = box.set_config(saveset)
end
if g_err.code == 0 and #delset > 0 then
g_err.code, g_err.msg = box.set_config(delset)
end
if g_err.code == 0 then
if box.post.gotoedit then
goto_edit_page(box.post.gotoedit)
else
http.redirect(href.get(box.glob.script))
end
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/kids.css"/>
<style type="text/css">
th.name, td.name {
overflow:hidden;
text-overflow: ellipsis;
}
td select {
font-size: inherit;
}
</style>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/dialog.js"></script>
<script type="text/javascript">
var sort=sorter();
function initTableSorter() {
sort.init("uiList");
sort.addTbl("uiDevices");
sort.addTbl("uiWinUsers");
sort.addTbl("uiGuests");
}
ready.onReady(initTableSorter);
function addHiddenInput(form, name, value) {
form = form || document.forms[0];
var hidden = document.createElement("input");
hidden.setAttribute("type", "hidden");
hidden.name = name;
hidden.value = value || "";
form.appendChild(hidden);
}
function initOnEditHandler() {
var confirmParams = {
Text1: "{?380:242?}",
Text2: "\n",
Text3: "{?380:857?}",
Buttons: [{
txt: "{?380:184?}",
cb: onConfirmYes
}, {
txt: "{?380:545?}",
cb: onConfirmNo
}
]
};
var form = document.forms[0];
var selects = form.getElementsByTagName("select");
var dirty = false;
var clicked = "";
function onChange(evt) {
var sel = jxl.evtTarget(evt);
if (sel.name.indexOf("profile:") == 0) {
dirty = true;
var btnId = sel.name.replace(/^profile:/, "uiEdit:");
var selValue = jxl.getValue(sel);
jxl.setValue(btnId, selValue);
jxl.setDisabled(btnId, selValue == "");
}
}
function onConfirmYes() {
addHiddenInput(form, "apply");
addHiddenInput(form, "gotoedit", clicked);
form.submit();
}
function onConfirmNo() {
addHiddenInput(form, "edit", clicked);
form.submit();
}
function onClick(evt) {
var btn = jxl.evtTarget(evt, "submit");
if (btn && btn.name == "edit" && dirty) {
clicked = jxl.getValue(btn);
dialog.messagebox(true, confirmParams);
return jxl.cancelEvent(evt);
}
}
var i = selects.length || 0;
while (i--) {
jxl.addEventHandler(selects[i], "change", onChange);
}
jxl.addEventHandler(form, "click", onClick);
}
ready.onReady(initOnEditHandler);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_error() ?>
<?lua write_explain() ?>
<?lua write_table() ?>
<br>
<div class="btn_form">
<button type="submit" name="cancel">{?txtRefresh?}</button>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
