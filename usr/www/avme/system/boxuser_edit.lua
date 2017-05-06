<?lua
g_page_type = "all"
g_page_title = [[{?45:197?}]]
g_page_help = "hilfe_system_userkonto.html"
g_menu_active_page = "/system/boxuser_settings.lua"
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"cmtable"
require"newval"
require"js"
require"boxusers"
require"http"
if boxusers.nasrights_possible() then
require"call_webusb"
end
g_user = {}
g_err = {}
g_onlyone_dir = false
g_show_vpn_popup = false
local uid = box.get.uid or box.post.uid or ""
g_new_user = uid == "new" or uid == ""
g_force_admin = false
local function get_path()
require("path_list")
local count, content = path_list.listSubDirs(0, "", "", "/", "/var/media/ftp/", false)
if count == 0 then
return html.p{
[[{?45:42?}]]
}.get()
end
return content
end
function write_dir_selection_js()
local result = {}
if boxusers.nasrights_possible() then
local head = html.div{class="sharing_head",
[[{?45:876?}]]
}
local content = html.fragment()
content.add(
html.hr{},
html.p{
[[{?45:481?}]]
},
html.div{class="formular",
html.input{
type="radio", tabindex="1", id="sharingAll", name="allOrOne", value="/",
onclick="onAllOrOne(false)", checked=true
},
html.label{["for"]="sharingAll",
[[{?45:828?}]]
},
html.br{},
html.input{type="radio", id="sharingOne", name="allOrOne", value="", onclick="onAllOrOne(true)"},
html.label{["for"]="sharingOne",
[[{?45:5041?}]]
}
},
html.div{class="listdir", id="listwrapper",
html.div{class="white_back", html.raw(get_path())}
}
)
local foot = html.div{
html.button{type="button", id="uiSelectOk", onclick="selectDir()",
[[{?txtOk?}]]
},
html.button{type="button", onclick="closeDirSelection()",
[[{?txtCancel?}]]
}
}
result = {
head = head.get(true),
content = content.get(true),
foot = foot.get(true)
}
end
box.out("{"..js.object(result).."}")
end
if box.get.ajax then
write_dir_selection_js()
box.end_page()
end
local function names_and_emails()
local curr_uid = box.post.uid or box.get.uid or ""
local result = boxusers.used_names(curr_uid)
return result
end
local function name_is_used(name)
local used = names_and_emails()
local value = box.post[name] or ""
value = value:lower()
return used[value]
end
local function read_user()
if not (box.get.uid or box.post.uid) or box.get.uid == "" or box.get.uid == "new" then
local user = boxusers.create_user()
if g_force_admin then
user.box_admin_rights = boxusers.convert_right(true, false)
end
g_box_vpn_activ = user.vpn_access == "1"
return user
else
local uid = box.get.uid or box.post.uid or ""
local i, user = array.find(boxusers.list, func.eq(uid, "UID"))
if box.get.uid then
if user then
user.frominternet = boxusers.frominternet(user)
g_box_vpn_activ = user.vpn_access == "1"
end
return user or {}
elseif box.post.uid then
user = user or {}
user.enabled = box.post.enabled and "1" or "0"
user.name = box.post.username or ""
user.email = box.post.email or ""
user.password = box.post.password or ""
user.frominternet = box.post.frominternet
for i, right in ipairs(boxusers.rights()) do
local hasright = box.post[right]
local value = "0"
if right == "vpn_access" then
if hasright then
value = "1"
end
else
value = boxusers.convert_right(hasright, user.frominternet)
end
user[right] = value
end
return user
end
end
end
local function save_user(saveset)
local prefix
if g_user.UID then
prefix = "boxusers:settings/user[" .. g_user.UID .. "]/"
else
prefix = "boxusers:settings/" .. box.query("boxusers:settings/user/newid") .. "/"
end
if g_force_admin or boxusers.is_myself(g_user) then
cmtable.add_var(saveset, prefix .. "enabled", "1")
else
cmtable.add_var(saveset, prefix .. "enabled", g_user.enabled)
end
cmtable.add_var(saveset, prefix .. "name", g_user.name)
cmtable.add_var(saveset, prefix .. "email", g_user.email)
cmtable.add_var(saveset, prefix .. "password", g_user.password)
local still_toset = array.truth(boxusers.rights())
if g_force_admin then
local value = boxusers.convert_right(true, g_user.frominternet)
cmtable.add_var(saveset, prefix .. "box_admin_rights", value)
cmtable.add_var(saveset, prefix .. "phone_rights", value)
still_toset.box_admin_rights = false
still_toset.phone_rights = false
elseif boxusers.is_myself(g_user) then
local value = boxusers.convert_right(box.post.my_box_admin_rights == "1", g_user.frominternet)
cmtable.add_var(saveset, prefix .. "box_admin_rights", value)
cmtable.add_var(saveset, prefix .. "phone_rights", value)
still_toset.box_admin_rights = false
still_toset.phone_rights = false
end
if ((box.query(prefix.."vpn_access") == "0") or not(g_user.UID)) and box.post.vpn_access then
g_show_vpn_popup = prefix
end
if config.VPN then
cmtable.save_checkbox(saveset,prefix.."vpn_access","vpn_access")
end
still_toset.vpn_access = false
for i, right in ipairs(boxusers.rights()) do
if still_toset[right] then
cmtable.add_var(saveset, prefix .. right, g_user[right])
end
end
end
local function add_dir(currdir, saveset, new_ids)
local webvar = "storagedirectories:settings/"
local found, dir = array.find(g_user.dirs, func.eq(currdir.path, "path"))
if found then
webvar = webvar .. dir._node
else
if nil == new_ids.dir then
new_ids.dir = box.query(webvar .. "directory/newid")
else
new_ids.dir = string.sub(new_ids.dir, 1, #new_ids.dir - 1) .. tostring(tonumber(string.sub(new_ids.dir, -1)) + 1)
end
webvar = webvar .. new_ids.dir
cmtable.add_var(saveset, webvar .. "/path", currdir.path)
end
if nil == new_ids[currdir.dirnode] then
new_ids[currdir.dirnode] = box.query(webvar .. "/access/entry/newid")
else
new_ids[currdir.dirnode] = string.sub(new_ids[currdir.dirnode], 1, #new_ids[currdir.dirnode] - 1) .. tostring(tonumber(string.sub(new_ids[currdir.dirnode], -1)) + 1)
end
webvar = webvar .. "/access/" .. new_ids[currdir.dirnode]
cmtable.add_var(saveset, webvar .. "/username", g_user.name)
local ro, rw = currdir.write or currdir.read, currdir.write
cmtable.add_var(saveset, webvar .. "/access_from_local", ro and "1" or "0")
cmtable.add_var(saveset, webvar .. "/write_access_from_local", rw and "1" or "0")
ro = ro and g_user.frominternet
rw = rw and g_user.frominternet
cmtable.add_var(saveset, webvar .. "/access_from_internet", ro and "1" or "0")
cmtable.add_var(saveset, webvar .. "/write_access_from_internet", rw and "1" or "0")
return saveset, new_ids
end
local function save_storagedirs(saveset)
g_user.dirs = boxusers.get_storagedirs()
local currdir = {}
local dirnode, path
local dir_err_codes, dir_err_msgs = {}, {}
local found, access
local delset = {}
for i, dir in ipairs(g_user.dirs) do
found, access = array.find(dir.access, func.eq(g_user.UID, "boxusers_UID"))
if found then
cmtable.add_var(delset,
"storagedirectories:command/" .. dir._node .. "/access/" .. access._node,
"delete"
)
end
end
cmtable.add_var(delset, "storagedirectories:settings/cleanup" , "1")
g_err.code, g_err.msg = box.set_config(delset)
if g_err.code ~= 0 then
return {}
end
g_user.dirs = boxusers.get_storagedirs()
if g_user.nas_rights ~= "0" then
local new_ids = {}
for i, name in ipairs(general.sorted_by_i(box.post)) do
if name:find("path_") == 1 then
currdir = {
dirnode = name:gsub("path_", ""),
path = box.post[name],
read = box.post[name:gsub("path_", "read_")],
write = box.post[name:gsub("path_", "write_")]
}
saveset, new_ids = add_dir(currdir, saveset, new_ids)
end
end
end
cmtable.add_var(saveset, "storagedirectories:settings/cleanup" , "1")
return saveset
end
local function validation()
newval.length("username", 1, 32, "name_err")
newval.no_end_char("username", 32, "name_err")
newval.char_range_regex("username", "boxusername", "name_err")
if not newval.value_empty("email") then
newval.char_range_regex("email", "email", "email_err")
end
if name_is_used("username") then
newval.const_error("username", "notdifferent", "name_used")
end
if name_is_used("email") then
newval.const_error("email", "notdifferent", "email_used")
end
if not newval.value_equal("password", "****") then
if newval.checked("frominternet") then
newval.not_empty("password", "pwd_required_internet")
end
if newval.checked("box_admin_rights") or newval.exists("force_admin") then
newval.not_empty("password", "pwd_required_boxconfig")
end
newval.length("password", 0, 32, "pwd_err")
newval.char_range_regex("password", "boxpassword", "pwd_err")
end
end
newval.msg.name_err = {
[newval.ret.outofrange] = [[{?45:198?}]]
}
newval.msg.name_err[newval.ret.tooshort] = newval.msg.name_err[newval.ret.outofrange]
newval.msg.name_err[newval.ret.toolong] = newval.msg.name_err[newval.ret.outofrange]
newval.msg.name_err[newval.ret.notfound] = newval.msg.name_err[newval.ret.outofrange]
newval.msg.name_err[newval.ret.endchar] = newval.msg.name_err[newval.ret.outofrange]
newval.msg.email_err = {
[newval.ret.outofrange] = [[{?45:93?}]]
}
newval.msg.email_err[newval.ret.notfound] = newval.msg.email_err[newval.ret.outofrange]
newval.msg.pwd_required_internet = {
[newval.ret.empty] = [[{?45:815?}]]
}
newval.msg.pwd_required_boxconfig = {
[newval.ret.empty] = [[{?45:186?}]]
}
newval.msg.pwd_err = {
[newval.ret.outofrange] = [[{?45:9480?}]]
}
newval.msg.pwd_err[newval.ret.tooshort] = newval.msg.pwd_err[newval.ret.outofrange]
newval.msg.pwd_err[newval.ret.toolong] = [[{?45:769?}]]
newval.msg.pwd_err[newval.ret.notfound] = newval.msg.pwd_err[newval.ret.outofrange]
newval.msg.name_used = {
[newval.ret.notdifferent] = [[{?45:122?}]]
}
newval.msg.email_used = {
[newval.ret.notdifferent] = [[{?45:366?}]]
}
if box.post.cancel then
http.redirect("/system/boxuser_list.lua")
end
g_box_vpn_activ = false
g_user = read_user()
if box.post.validate == "apply" then
local valresult, answer = newval.validate(validation)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
if newval.validate(validation) == newval.ret.ok then
local saveset = {}
save_user(saveset)
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
saveset = {}
if boxusers.nasrights_possible() then
saveset = save_storagedirs(saveset)
if g_err.code == 0 then
g_err.code, g_err.msg = box.set_config(saveset)
end
end
if g_err.code == 0 then
local popup = ""
if g_show_vpn_popup then
boxusers.refresh_list()
local user = boxusers.get_user_by_name(g_user.name)
if user then
popup = "?vpn_popup="..box.RFC1630_Escape(user.UID,true)
end
end
http.redirect("/system/boxuser_list.lua"..popup)
end
end
end
end
function write_save_error()
if (g_err.code and g_err.code ~= 0) then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
local function rights_checkbox(which, txt, explain, link_tab)
local checkbox = html.input{type="checkbox", name=which}
checkbox.id = "ui" .. which:at(1):upper() .. which:sub(2)
checkbox.checked = g_user[which] ~= "0"
if which == "box_admin_rights" or which == "phone_rights" or which == "homeauto_rights" then
checkbox.checked = checkbox.checked or g_force_admin
checkbox.checked = checkbox.checked or g_new_user
checkbox.disabled = boxusers.is_myself(g_user) or g_force_admin
end
local my_box_admin_rights
if which == "box_admin_rights" and boxusers.is_myself(g_user) then
my_box_admin_rights = html.input{type="hidden", name="my_box_admin_rights", value=checkbox.checked and "1" or "0"}
end
local link = nil
if link_tab then
link = html.a{
href=link_tab.href, onclick=link_tab.onclick, id=link_tab.id, style=link_tab.style,
link_tab.txt
}
end
return html.div{class="formular",
checkbox,
html.label{["for"]=checkbox.id, txt},
html.p{class="form_checkbox_explain", explain, link},
my_box_admin_rights
}
end
function write_rights()
rights_checkbox("box_admin_rights",
[[{?45:350?}]],
[[{?45:357?}]]
).write()
local fritz_app_activ = false
if config.FON and (config.DECT or config.AB_COUNT > 0 or fritz_app_activ) then
rights_checkbox("phone_rights",
[[{?45:398?}]],
[[{?45:594?}]]
).write()
end
if boxusers.nasrights_possible() then
rights_checkbox("nas_rights",
[[{?45:867?}]],
[[{?45:67?}]]
).write()
box.out([[
<div class="showif_nasrights formular">
<div class="formular">
<p>
]])
if g_onlyone_dir then
box.html([[{?45:873?}]])
else
box.html([[{?45:83?}]])
end
box.out([[
</p>
<table id="uiDirs" class="zebra">
<tr class="thead">
<th class="sortable">]]..box.tohtml([[{?45:291?}]])..[[<span class="sort_no">&nbsp;</span></th>
<th class="tableCheck">]]..box.tohtml([[{?45:709?}]])..[[</th>
<th class="tableCheck">]]..box.tohtml([[{?45:440?}]])..[[</th>
<th class="buttonrow"></th>
</tr>
]])
write_dirs()
box.out([[
</table>
<div class="btn_form">
<button type="button" id="uiAddDir">]]..box.tohtml([[{?45:659?}]])..[[</button>
<button type="button" id="uiDeleteDirs">]]..box.tohtml([[{?45:109?}]])..[[</button>
</div>
</div>
</div>
]])
end
if config.HOME_AUTO then
rights_checkbox("homeauto_rights",
[[{?45:770?}]],
[[{?45:590?}]]
).write()
end
if config.VPN then
rights_checkbox("vpn_access",
[[{?45:380?}]],
[[{?45:89?}]],
{
href=href.get([[/system/vpn_print.lua]], http.url_param("uid", g_user.UID or "")),
id="vpn_access_link",
style="display:none;",
txt=[[{?45:906?}]],
onclick="return onVpnLink(this);"
}
).write()
end
end
function write_enabled_checkbox()
local disabled = false
if boxusers.is_myself(g_user) or g_force_admin then
disabled = true
end
html.input{
type="checkbox", name="enabled", id="uiEnabled",
checked=g_user.enabled == "1",
disabled = disabled
}.write()
html.label{["for"]="uiEnabled", [[{?45:735?}]]}.write()
end
function write_name()
box.html(g_user.name or "")
end
function write_email()
box.html(g_user.email or "")
end
function write_password()
box.html(g_user.password or "")
end
function write_frominternet_checkbox()
html.input{
type="checkbox", name="frominternet", id="uiFrominternet", checked = g_user.frominternet or g_new_user
}.write()
html.label{["for"]="uiFrominternet", [[{?45:574?}]]}.write()
end
function write_hidden_values()
html.input{type="hidden", name="uid", value=g_user.UID or ""}.write()
if g_force_admin then
html.input{type="hidden", id="uiForce_admin", name="force_admin", value=""}.write()
end
end
local dirs_emptytxt = [[{?45:730?}]]
function write_dirs_emptytxt_js()
box.js(dirs_emptytxt)
end
function write_dirs()
local dirs = boxusers.get_storagedirs()
table.sort(dirs, function(d1, d2) return (d1.path or "") < (d2.path or "") end)
local empty = true
local display_path
for i, dir in ipairs(dirs) do
local access = boxusers.get_access(g_user, dir, g_user.frominternet)
if access then
display_path = (dir.path or ""):gsub("^/", "")
if display_path == "" then
display_path = [[{?45:108?}]]
end
empty = false
html.tr{class=dir.status == "0" and "notpresent" or nil,
html.td{title=dir.path or "",
html.p{class="pathdisplay", display_path},
html.input{type="hidden", name= "path_" .. dir._node, value=dir.path or ""}
},
html.td{ class="tableCheck",
html.input{type="checkbox", id="uiRead_" .. dir._node, name="read_" .. dir._node, checked=access.read}
},
html.td{ class="tableCheck",
html.input{type="checkbox", id="uiWrite_" .. dir._node, name="write_" .. dir._node, checked=access.write}
},
html.td{class="buttonrow",
html.button{
type="button", class="icon", id="uiDelete_" .. dir._node, title=[[{?45:728?}]],
html.img{src="/css/default/images/loeschen.gif"}
}
}
}.write()
end
end
if empty then
html.tr{class="emptylist",
html.td{colspan=4, dirs_emptytxt}
}.write()
end
end
function write_hidenas_css()
if not boxusers.nasrights_possible() then
box.out([[.showif_nasrights {display: none;}]])
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/disable_page.css"/>
<link rel="stylesheet" type="text/css" href="/css/default/dir_dialog.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<style type="text/css">
table#uiDirs tr th:first-child,
table#uiDirs tr td:first-child {
width: 480px;
}
p.pathdisplay {
width: 480px;
white-space:nowrap;
overflow:hidden;
text-overflow:ellipsis;
}
table#uiDirs tr.notpresent td:first-child {
color: #888888;
}
.tableCheck {
text-align: center;
width: 80px;
}
.disable_main_page_content_box,
#disable_main_page_content_box {
width: 560px;
margin-left:auto;
margin-right:auto;
margin-top: 8%;
border: 1px solid #8da4a3;
background-color: #faf9f6;
padding: 4px 8px;
font-size: 13px;
font-family: Arial;
color: #3f464c;
}
#disable_main_page_content_foot {
text-align:right;
}
.sharing_head {
padding-top: 5px;
font-size: 14px;
font-weight: bold;
}
.white_back {
max-height: 250px;
overflow:auto;
background-color:#FFFFFF;
border: 1px solid #c6c7be;
font-size: 12px;
}
<?lua write_hidenas_css() ?>
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/disable_page.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
var sort=sorter();
function onVpnLink(link) {
if (link && link.href) {
window.open(link.href, "VpnEinstellungen", "width=600,height=830,scrollbars=yes,resizable=yes");
}
return false;
}
var g_onlyoneDir = <?lua box.js(tostring(g_onlyone_dir)) ?>;
function checkEmptyTr() {
var tbl = jxl.get("uiDirs");
if (tbl.rows.length == 1) {
var tr = tbl.insertRow(1);
tr.className = "emptylist";
var td = document.createElement('td');
td.colSpan = 4;
td.innerHTML = "<?lua write_dirs_emptytxt_js() ?>";
tr.appendChild(td);
}
else if (tbl.rows.length > 1) {
if (jxl.hasClass(tbl.rows[1], "emptylist")) {
tbl.deleteRow(1);
}
}
zebra();
}
function onlyOneDirCheck() {
if (g_onlyoneDir) {
var tbl = jxl.get("uiDirs");
jxl.display("uiAddDir", jxl.hasClass(tbl.rows[1], "emptylist"));
}
}
function initDeleteDirHandlers() {
var tbl = jxl.get("uiDirs");
function onDeleteDir(evt) {
var btn = jxl.evtTarget(evt, "button");
if (btn && btn.type == "button") {
var tr = btn;
while (tr && typeof tr.rowIndex != 'number') {
tr = tr.parentNode;
}
if (tr) {
tbl.deleteRow(tr.rowIndex);
}
}
checkEmptyTr();
onlyOneDirCheck();
}
function onDeleteAll(evt) {
while (tbl.rows.length > 1) {
tbl.deleteRow(1);
}
checkEmptyTr();
onlyOneDirCheck();
}
if (tbl) {
jxl.addEventHandler("uiDirs", "click", onDeleteDir);
jxl.addEventHandler("uiDeleteDirs", "click", onDeleteAll);
}
}
function findSortSlot(pathName) {
var tbl = jxl.get("uiDirs");
var rows = tbl.rows;
for (var i = 1; i < rows.length; i++) {
var hidden = rows[i].cells[0].getElementsByTagName("input");
var txt = "";
if (hidden && hidden.length) {
txt = jxl.getValue(hidden[0]);
}
if (pathName == txt) {
return false;
}
if (pathName < txt) {
return i;
}
}
return rows.length;
}
function createDeleteButton(idx) {
var btn = document.createElement('button');
btn.setAttribute("type", "button");
btn.className = "icon";
btn.id = "uiDelete_new" + idx;
btn.title = "{?45:983?}";
var img = document.createElement('img');
img.src = "/css/default/images/loeschen.gif";
btn.appendChild(img);
return btn;
}
function createHiddenPathInput(idx, pathName) {
var hidden = document.createElement('input');
hidden.setAttribute("type", "hidden");
hidden.name = "path_new" + idx;
hidden.value = pathName;
return hidden;
}
function createCheckbox(idx, idPrefix, namePrefix) {
var cBox = document.createElement('input');
cBox.setAttribute("type", "checkbox");
cBox.checked = true;
cBox.id = idPrefix + "_new" + idx;
cBox.name = namePrefix + "_new" + idx;
return cBox;
}
var g_newDirs = 0;
function addToDirs(pathName) {
pathName = pathName || "";
var slot = findSortSlot(pathName);
if (slot) {
g_newDirs++;
var tbl = jxl.get("uiDirs");
var tr = tbl.insertRow(slot);
var td = document.createElement('td');
td.title = pathName;
var displayPathName = pathName.replace(/^\//, "");
displayPathName = displayPathName || "{?45:896?}";
var p = document.createElement("p");
p.className = "pathdisplay";
p.appendChild(document.createTextNode(displayPathName));
td.appendChild(p);
var hidden = createHiddenPathInput(g_newDirs, pathName);
td.appendChild(hidden);
tr.appendChild(td);
td = document.createElement('td');
td.className = "tableCheck";
var cBox = createCheckbox(g_newDirs, "uiRead", "read");
td.appendChild(cBox);
tr.appendChild(td);
td = document.createElement('td');
td.className = "tableCheck";
cBox = createCheckbox(g_newDirs, "uiWrite", "write");
td.appendChild(cBox);
tr.appendChild(td);
td = document.createElement('td');
td.className = "buttonrow";
var btn = createDeleteButton(g_newDirs);
td.appendChild(btn);
tr.appendChild(td);
zebra();
}
checkEmptyTr();
onlyOneDirCheck();
}
function onDirClick(evt) {
var clickedBox = jxl.evtTarget(evt);
var readBox, writeBox;
if (clickedBox && clickedBox.type == "checkbox") {
if (clickedBox.id.indexOf("uiRead_") == 0) {
readBox = clickedBox;
writeBox = clickedBox.id.replace("uiRead_", "uiWrite_");
if (!jxl.getChecked(readBox)) {
jxl.setChecked(writeBox, false);
}
}
else if (clickedBox.id.indexOf("uiWrite_") == 0) {
writeBox = clickedBox;
readBox = clickedBox.id.replace("uiWrite_", "uiRead_");
if (jxl.getChecked(writeBox)) {
jxl.setChecked(readBox, true);
}
}
}
}
function onRightsClick(evt) {
var clickedBox = jxl.evtTarget(evt);
if (clickedBox && clickedBox.type == "checkbox") {
var adminBox = jxl.get("uiBox_admin_rights");
var phoneBox = jxl.get("uiPhone_rights");
var homeautoBox = jxl.get("uiHomeauto_rights");
var vpnBox = jxl.get("uiVpn_access");
if (clickedBox == phoneBox || clickedBox == homeautoBox) {
if (adminBox.disabled) {
return jxl.cancelEvent(evt);
}
else if (clickedBox == phoneBox && jxl.getChecked(adminBox) && !jxl.getChecked(phoneBox)) {
jxl.setChecked(adminBox, false);
jxl.setChecked(homeautoBox, false);
}
else if (clickedBox == homeautoBox && jxl.getChecked(adminBox) && !jxl.getChecked(homeautoBox)) {
jxl.setChecked(adminBox, false);
jxl.setChecked(phoneBox, false);
}
}
else if (clickedBox == adminBox) {
if (jxl.getChecked(adminBox)) {
jxl.setChecked(phoneBox, true);
jxl.setChecked(homeautoBox, true);
}
}
else if (clickedBox == vpnBox && <?lua box.js(tostring(g_box_vpn_activ)) ?>) {
jxl.display("vpn_access_link", jxl.getChecked(vpnBox));
}
}
}
var g_refreshList = [];
var g_breakRefresh = false;
var g_currentRefresh = null;
var g_currentRefreshPath;
var g_defPath = [];
var g_defPathIdx = 0;
var g_defCurrPath = "";
var gUrl =
encodeURI("/lua/verz_liste_async.lua") + "?" +
buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
function startRefresh() {
if (g_refreshList.length > 0 && g_currentRefresh==null) {
g_currentRefresh = g_refreshList.pop();
var inp = g_currentRefresh.getElementsByTagName("input");
for (var i = 0; i < inp.length; i++) {
if (inp[i].name == "dir") {
g_currentRefreshPath = inp[i].value;
ajaxGet(gUrl + "&" + buildUrlParam("dir", inp[i].value), refreshCb);
break;
}
}
}
}
function refreshCb(xhr) {
if (xhr && xhr.responseXML) {
var resp = xhr.responseXML.documentElement;
if (resp) {
var nodes = resp.getElementsByTagName("dir");
if (nodes && nodes.length) {
var list = document.createElement("ul");
if (g_defPathIdx==0 || g_defPathIdx==g_defPath.length-1 || g_defCurrPath+"/"+g_defPath[g_defPathIdx]!=g_currentRefreshPath) {
list.style.display = "none";
}
var parentinp = g_currentRefresh.firstChild;
while (parentinp && parentinp.nodeName.toLowerCase()!="input") {
parentinp = parentinp.nextSibling;
}
for (var i=0; i<nodes.length; i++) {
var elem = document.createElement("li");
elem.className="incomplete";
elem.innerHTML =
'<input type="radio" name="dir" id="'+parentinp.id + "_" + i+
'" value="'+parentinp.value + "/" + nodes[i].childNodes[0].nodeValue+
'" onclick="enableOk()"> '+
'<label for="'+parentinp.id + "_" + i+'">'+nodes[i].childNodes[0].nodeValue+'</label>';
list.appendChild(elem);
}
g_currentRefresh.appendChild(list);
addHideButton(g_currentRefresh, list);
}
else {
nodes = resp.getElementsByTagName("error");
if (nodes && nodes.length) {
var tmp = '<p>'+nodes[0].childNodes[0].nodeValue+'</p><p>{?45:809?}</p><hr>';
jxl.setHtml("uiViewContentBox", tmp);
g_breakRefresh = true;
}
}
jxl.removeClass(g_currentRefresh, "incomplete");
if (g_defPathIdx!=0) {
if (g_defPathIdx==g_defPath.length-1) {
if (g_currentRefreshPath == g_defCurrPath+"/"+g_defPath[g_defPathIdx]) {
checkByLi(g_currentRefresh);
g_defPathIdx = 0;
}
}
else {
var nextdef = findPathLi(g_currentRefresh, g_defCurrPath+"/"+g_defPath[g_defPathIdx]);
if (nextdef) {
g_defCurrPath = g_defCurrPath+"/"+g_defPath[g_defPathIdx];
g_defPathIdx++;
var sub = nextdef.getElementsByTagName("ul");
if (sub && sub.length) {
sub[0].style.display = "";
iefix();
checkIncomplete(sub[0]);
}
}
}
}
g_currentRefresh = null;
}
else {
g_currentRefresh = null;
}
}
else {
g_currentRefresh = null;
}
if (g_currentRefresh==null && !g_breakRefresh) {
startRefresh();
}
}
function checkIncomplete(list) {
var child = list.getElementsByTagName("li");
g_breakRefresh = true;
for (var i=child.length-1; i>=0; i--) {
if (jxl.hasClass(child[i], "incomplete")) {
g_refreshList.push(child[i]);
}
}
g_breakRefresh = false;
startRefresh();
}
function iefix() {
if (navigator.userAgent.indexOf("MSIE ")!=-1) {
var div = document.getElementById("listwrapper");
var save = "";
var inp = jxl.getByName("dir", div);
for (var i=0; inp && i < inp.length; i++) {
if (inp[i].checked) {
save = inp[i].value;
break
}
}
var ul = div.removeChild(div.firstChild);
div.appendChild(ul);
var inp = jxl.getByName("dir", div);
for (var i=0; inp && i < inp.length; i++) {
if (inp[i].value == save) {
inp[i].checked = true;
enableOk();
break
}
}
}
}
function toggleSubTree(img, list) {
if (list.style.display=="none") {
list.style.display = "";
img.src = "/css/default/images/schliessen.gif";
checkIncomplete(list);
}
else {
list.style.display = "none";
img.src = "/css/default/images/oeffnen.gif";
}
iefix();
}
function addHideButton(item, list) {
var img = document.createElement("img");
if (list.style.display=="none") {
img.src = "/css/default/images/oeffnen.gif";
}
else {
img.src = "/css/default/images/schliessen.gif";
}
img.style.position = "absolute";
img.onclick = function() { toggleSubTree(img, list); }
item.insertBefore(img, item.firstChild);
}
function checkByLi(li) {
var inp = li.getElementsByTagName("input");
if (inp && inp.length > 0) {
inp[0].checked =true;
enableOk();
}
}
function findPathLi(parent, path) {
var radios = parent.getElementsByTagName("input");
for (var i=0; i<radios.length; i++) {
if (radios[i].value == path) {
return radios[i].parentNode;
}
}
return null;
}
function addTreeCtrls() {
var div = jxl.get("listwrapper");
var listitems = div.getElementsByTagName("li");
for (var i=0; i<listitems.length; i++) {
var sub = listitems[i].getElementsByTagName("ul");
if (sub && sub.length) {
addHideButton(listitems[i], sub[0]);
}
}
}
function enableOk() {
}
function onAllOrOne(val) {
jxl.display("listwrapper", val);
}
var json = makeJSONParser();
var dirSelectionInnerHtml = null;
function cbDirSelection(response)
{
if (response && response.status == 200)
{
var resp = json(response.responseText);
if (resp)
{
if ( gDisableMainPageBox=="first" ) {
gDisableMainPageBox = createModalBox(createBoxContent("all"));
}
fillBoxContent(resp.head, resp.content, resp.foot);
}
}
}
function showDirSelection() {
if ( gDisableMainPageBox=="first" ) {
gDisableMainPageBox = createModalBox(createBoxContent("all"));
fillBoxContent("<p style='text-align:center;'>{?45:2883?}</p>", "<p class='waitimg'><img style='margin: auto;' alt='' src='/css/default/images/wait.gif'></p>", "<button type='button' onclick='closeDirSelection()'>{?txtCancel?}</button>");
}
gDisableMainPageBox.open();
addTreeCtrls();
onAllOrOne(jxl.getChecked("sharingOne"));
}
function closeDirSelection() {
gDisableMainPageBox.close();
}
function selectDir() {
if (jxl.getChecked("sharingAll")) {
addToDirs("/");
}
else {
var noSelection = true;
var radios = jxl.getByName("dir");
for (var i=0; i<radios.length; i++) {
if (radios[i].checked) {
noSelection = false;
addToDirs(radios[i].value);
break;
}
}
if (noSelection) {
alert("{?45:224?}");
return;
}
}
closeDirSelection();
}
function init() {
createPasswordChecker( "uiPassword" );
ajaxGet("<?lua href.write([[/cgi-bin/luacgi_notimeout]], [[script=]]..box.glob.script, [[ajax=1]]) ?>", cbDirSelection);
showOnClick({
inputName: "nas_rights",
classString: "showif_nasrights"
});
initDeleteDirHandlers();
jxl.addEventHandler("uiAddDir", "click", showDirSelection);
jxl.addEventHandler("uiDirs", "click", onDirClick);
jxl.addEventHandler("uiRights", "click", onRightsClick);
jxl.display("vpn_access_link", jxl.getChecked("uiVpn_access"));
onlyOneDirCheck();
if (g_onlyoneDir) {
jxl.hide("uiDeleteDirs");
}
}
function initTableSorter() {
sort.init("uiDirs");
sort.setDirection(0,-1);
sort.sort_table(0);
}
ready.onReady(initTableSorter);
ready.onReady(init);
function comfirmNoDirRights() {
if (jxl.getChecked("uiNas_rights")) {
var readBoxes = jxl.walkDom("uiDirs", "input", function(el) {
return (el.id && el.id.indexOf("uiRead_") == 0);
});
var txt = "";
if (!readBoxes.length) {
txt = "{?45:246?}";
}
else {
var anyUnchecked = false;
for (var i = 0; i < readBoxes.length; i++) {
if (!readBoxes[i].checked) {
anyUnchecked = true;
break;
}
}
if (anyUnchecked) {
txt = "{?45:941?}";
if (g_onlyoneDir) {
txt = "{?45:764?}";
}
}
}
if (txt) {
return confirm(txt + "\n" + "{?45:573?}");
}
}
return true;
}
ready.onReady(ajaxValidation({
okCallback: comfirmNoDirRights
}));
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<?lua write_save_error() ?>
<p>
{?45:358?}
</p>
<hr>
<h4>{?45:422?}</h4>
<div id="uiUser" class="widetext">
<div class="formular">
<?lua write_enabled_checkbox() ?>
</div>
<div class="formular">
<label for="uiUsername">{?45:386?}</label>
<input type="text" name="username" id="uiUsername" maxlength="32" value="<?lua write_name() ?>">
</div>
<div class="formular">
<label for="uiEmail">{?45:526?}</label>
<input type="text" name="email" id="uiEmail" value="<?lua write_email() ?>">
</div>
<div class="formular">
<label for="uiPassword">{?45:609?}</label>
<input type="text" name="password" id="uiPassword" maxlength="32" autocomplete="off" value="<?lua write_password() ?>" >
</div>
</div>
<hr>
<h4>{?45:978?}</h4>
<div class="formular">
<?lua write_frominternet_checkbox() ?>
</div>
<hr>
<h4>{?45:925?}</h4>
<div id="uiRights">
<?lua write_rights() ?>
</div>
<?lua write_hidden_values() ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div id="btn_form_foot">
<button type="submit" name="apply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
