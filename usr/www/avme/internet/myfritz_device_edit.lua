<?lua
g_page_type = "all"
g_page_title = [[{?4617:447?}]]
g_page_help = "hilfe_internet_myfritz_edit_freigabe.html"
g_menu_active_page = "/internet/myfritz_devicelist.lua"
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"js"
require"cmtable"
require"newval"
require"http"
require"href"
g_back_to_page = http.get_back_to_page( g_menu_active_page )
g_err = {}
if box.post.cancel or ( not box.get.edit and not box.post.edit ) then
http.redirect(g_back_to_page)
end
g_schemes = {
{display = "http://", value = "http://"},
{display = "https://", value = "https://"},
{display = "ftp://", value = "ftp://"}
}
g_default_apps = {
{Name = [[HTTP-Server]], Scheme = "http://", Port = "80"},
{Name = [[HTTPS-Server]], Scheme = "https://", Port = "443"},
{Name = [[FTP-Server]], Scheme = "ftp://", Port = "21"}
}
g_dev = {}
local function valprog()
newval.msg.no_lan = {
[newval.ret.wrong] = [[{?4617:850?}]]
}
newval.msg.no_app = {
[newval.ret.wrong] = [[{?4617:989?}]]
}
newval.msg.no_scheme = {
[newval.ret.wrong] = [[{?4617:459?}]]
}
local empty_scheme_err = [[{?4617:523?}]]
newval.msg.empty_scheme = {
[newval.ret.empty] = empty_scheme_err,
[newval.ret.notfound] = empty_scheme_err
}
newval.msg.empty_name = {
[newval.ret.empty] = [[{?4617:530?}]]
}
local port_err = [[{?4617:452?}]]
newval.msg.port_err = {
[newval.ret.empty] = port_err,
[newval.ret.notfound] = port_err,
[newval.ret.format] = port_err,
[newval.ret.outofrange] = port_err
}
if newval.value_equal("landevice", "choose") then
newval.const_error("landevice", "wrong", "no_lan")
end
if newval.value_equal("app", "choose") then
newval.const_error("app", "wrong", "no_app")
end
if newval.value_equal("app", "other") then
newval.not_empty("appname", "empty_name")
if newval.value_equal("Scheme", "choose") then
newval.const_error("Scheme", "wrong", "no_scheme")
end
if newval.value_equal("Scheme", "userdef") then
newval.not_empty("userdefscheme", "empty_scheme")
end
newval.not_empty("Port", "port_err")
newval.num_range("Port", 1, 65535, "port_err")
end
end
local function get_landevices()
local list = general.listquery(
"landevice:settings/landevice/list(UID,name,guest,myfritz_enabled,myfritzdevice_UID,ip,ipv6_ifid,neighbour_name)"
)
list = array.filter(list, function(dev)
return dev.guest ~= "1" and (dev.ip ~= "" or dev.ipv6_ifid ~= "" or dev.neighbour_name ~= "")
end)
return list
end
local function split_value(value)
local t = (value or ""):split(":")
return {device_uid = t[1], service_node = t[2]}
end
local function path_display(path)
return ((path or ""):gsub("^/", ""))
end
local function path_value(path)
path = path or ""
if path:find("/") ~= 1 then
path = "/" .. path
end
return path
end
local function get_device_uid(lan_uid)
local uid = box.query("landevice:settings/landevice[" .. lan_uid .. "]/myfritzdevice_UID")
if uid == "" then return nil end
return uid
end
local function get_device_value(device_uid, service_node, which)
local result
local webvar = [[myfritzdevice:settings/device[%s]/services/%s/]]
if device_uid and service_node then
result = box.query(webvar:format(device_uid, service_node) .. which)
end
if result == "" then result = nil end
return result
end
local function find_default_app(device_uid, service_node)
local app = {
Name = get_device_value(device_uid, service_node, "Name") or "",
Scheme = get_device_value(device_uid, service_node, "Scheme") or "",
Port = get_device_value(device_uid, service_node, "Port") or ""
}
for i, default_app in ipairs(g_default_apps) do
local found = true
for k, v in pairs(app) do
found = found and v == default_app[k]
if not found then break end
end
if found then
return i, default_app
end
end
end
local function get_address_templates()
local result = {}
local myfritz_url = box.query("jasonii:settings/dyndnsname")
if not myfritz_url or myfritz_url == "" then
return result
end
local list = general.listquery(
"myfritzdevice:settings/device/list(landevice_UID,dyndnslabel)"
)
for i, dev in ipairs(list) do
if dev.dyndnslabel ~= "" then
local url = dev.dyndnslabel .. "." .. myfritz_url
result[dev.landevice_UID] = [[%1]] .. url .. [[:%2%3]]
end
end
if next(result) then
result[""] = [[{?4617:592?}]]
end
return result
end
local function delete_device(landevice_uid, device_uid, service_node)
local saveset = {}
local webvar = "myfritzdevice:command/device[" .. device_uid .. "]/services/"
cmtable.add_var(saveset, webvar .. service_node, "delete")
webvar = webvar:gsub(":command/", ":settings/")
local cnt_services = tonumber(box.query(webvar .. "entry/count")) or 0
if cnt_services <= 1 then
webvar = "landevice:settings/landevice[" .. landevice_uid .. "]/myfritz_enabled"
cmtable.add_var(saveset, webvar, "0")
end
local err = {}
err.code, err.msg = box.set_config(saveset)
return err.code, err.msg
end
local function create_device(landevice_uid)
local saveset = {}
cmtable.add_var(saveset,
"landevice:settings/landevice[" .. box.post.landevice .. "]/myfritz_enabled", "1"
)
local err = {}
err.code, err.msg = box.set_config(saveset)
return err.code, err.msg
end
local function read_userinput(dev)
local i, app = array.find(g_default_apps, func.eq(box.post.app, "Name"))
if not app then
app = {
Name = box.post.appname or "",
Scheme = box.post.Scheme or "",
Port = box.post.Port or "",
}
if app.Scheme == "userdef" then
app.Scheme = box.post.userdefscheme or ""
end
end
app.URLPath = box.post.URLPath or ""
return table.update(dev, app)
end
local function save_device(dev)
local webvar = [[myfritzdevice:settings/device[%s]/services/%s/]]
webvar = webvar:format(dev.device_uid, dev.service_node)
local saveset = {}
cmtable.add_var(saveset, webvar .. "Name", dev.Name)
cmtable.add_var(saveset, webvar .. "Scheme", dev.Scheme)
cmtable.add_var(saveset, webvar .. "Port", dev.Port)
cmtable.add_var(saveset, webvar .. "URLPath", path_value(dev.URLPath))
cmtable.add_var(saveset, webvar .. "Enabled", "1")
local err = {}
err.code, err.msg = box.set_config(saveset)
return err.code, err.msg
end
g_dev = split_value(box.get.edit or box.post.edit)
if box.post.validate == "apply" then
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply and newval.validate(valprog) == newval.ret.ok then
local landevice_changed = box.post.orig_landevice and box.post.orig_landevice ~= box.post.landevice
if landevice_changed then
g_err.code, g_err.msg = delete_device(box.post.orig_landevice, g_dev.device_uid, g_dev.service_node)
g_dev = {}
end
if not landevice_changed or g_err.code == 0 then
g_dev.device_uid = get_device_uid(box.post.landevice)
if not g_dev.device_uid then
g_err.code, g_err.msg = create_device(box.post.landevice)
end
if g_dev.device_uid or g_err.code == 0 then
g_dev.device_uid = g_dev.device_uid or get_device_uid(box.post.landevice)
end
if g_dev.device_uid then
if not g_dev.service_node then
g_dev.service_node = box.query(
string.format([[myfritzdevice:settings/device[%s]/services/entry/newid]], g_dev.device_uid)
)
end
g_dev = read_userinput(g_dev)
g_err.code, g_err.msg = save_device(g_dev)
if g_err.code == 0 then
local ipv4ForwardingWarning = get_device_value(g_dev.device_uid, g_dev.service_node, "IPv4ForwardingWarning")
http.redirect(
href.get(g_back_to_page, http.url_param("ipv4ForwardingWarning", ipv4ForwardingWarning or ""))
)
end
end
end
else
if g_dev.device_uid ~= "new" then
g_dev.Name = get_device_value(g_dev.device_uid, g_dev.service_node, "Name")
g_dev.Scheme = get_device_value(g_dev.device_uid, g_dev.service_node, "Scheme")
g_dev.Port = get_device_value(g_dev.device_uid, g_dev.service_node, "Port")
g_dev.URLPath = get_device_value(g_dev.device_uid, g_dev.service_node, "URLPath")
end
end
function write_landevice_select()
local landevices = get_landevices()
local orig_landevice
local sel = html.select{id="uiLandevice", name="landevice"}
if g_dev.device_uid == "new" then
sel.add(
html.option{value="choose", [[{?txtPleaseSelect?}]]}
)
end
for i, landevice in ipairs(landevices) do
local selected = landevice.myfritzdevice_UID == g_dev.device_uid
if selected then
orig_landevice = landevice.UID
end
sel.add(html.option{value=landevice.UID, selected=selected, landevice.name})
end
if orig_landevice then
html.input{type="hidden", name="orig_landevice", value=orig_landevice}.write()
end
html.div{class="formular widetext",
html.label{["for"]="uiLandevice", [[{?4617:50?}]]},
sel
}.write()
end
function write_app_select()
if g_dev.device_uid == "new" then
local sel = html.select{id="uiApp", name="app"}
sel.add(
html.option{value="choose", selected=true, [[{?txtPleaseSelect?}]]}
)
for i, app in ipairs(g_default_apps) do
sel.add(html.option{value=app.Name, app.Name})
end
sel.add(html.option{value="other",
[[{?4617:301?}]]}
)
html.div{class="formular",
html.label{["for"]="uiApp", [[{?4617:722?}]]},
sel
}.write()
else
html.input{type="hidden", id="uiApp", name="app", value="other"}.write()
end
end
function write_scheme_select()
local div = html.div{class="formular"}
div.add(html.label{["for"]="uiScheme", [[{?4617:921?}]]})
local sel = html.select{id="uiScheme", name="Scheme"}
local show_choose = g_dev.device_uid == "new"
if show_choose then
sel.add(html.option{value="choose",
[[{?txtPleaseSelect?}]]
})
end
local userdef_selected = not show_choose
local selected
for i, scheme in ipairs(g_schemes) do
if not show_choose then
selected = g_dev.Scheme == scheme.value
if selected then
userdef_selected = false
end
end
sel.add(html.option{value=scheme.value, selected=selected, scheme.display})
end
sel.add(html.option{value="userdef", selected=userdef_selected, [[{?4617:95?}]]})
div.add(sel)
div.write()
local userdef_value = ""
if userdef_selected then
userdef_value = g_dev.Scheme
end
div = html.div{class="formular", id="uiUserdefDiv"}
div.add(html.label{["for"]="uiUserdefscheme"})
div.add(html.input{type="text", name="userdefscheme", id="uiUserdefscheme", value=userdef_value})
div.write()
end
function write_appname()
box.html(g_dev.Name or "")
end
function write_path()
box.html(path_display(g_dev.URLPath))
end
function write_port()
box.html(g_dev.Port or "")
end
function write_address_templates_js()
local address_templates = get_address_templates()
if next(address_templates) then
box.out(js.table(address_templates))
else
box.js([[null]])
end
end
function write_default_apps_js()
local result = {}
if g_dev.device_uid == "new" then
for i, app in ipairs(g_default_apps) do
result[app.Name] = app
end
end
box.out(js.table(result))
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.formular span.label {
display: inline-block;
width: 200px;
margin-right: 6px;
}
span#uiAddress {
height: auto;
}
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
function pathValue(path) {
path = path || "";
if (path.indexOf("/") != 0) {
path = "/" + path;
}
return path;
}
function initChangeHandler() {
var toShowIfOther = jxl.getByClass("showif_other");
var addressTemplates = <?lua write_address_templates_js() ?>;
var defaultApps = <?lua write_default_apps_js() ?>;
var scheme, port, urlPath;
function updateAddress(evt) {
if (addressTemplates) {
var landevice = jxl.getValue("uiLandevice");
var template = addressTemplates[landevice];
var app = jxl.getValue("uiApp");
if (app == "other") {
scheme = jxl.getValue("uiScheme");
if (scheme == "choose") {
scheme = "";
}
if (scheme == "userdef") {
scheme = jxl.getValue("uiUserdefscheme");
}
port = jxl.getValue("uiPort");
}
else if (defaultApps[app]) {
scheme = defaultApps[app].Scheme;
port = defaultApps[app].Port;
}
urlPath = pathValue(jxl.getValue("uiURLPath"));
if (template && scheme && port) {
jxl.setText("uiAddress", jxl.sprintf(template, scheme, port, urlPath));
}
else {
jxl.setHtml("uiAddress", "&nbsp;");
}
}
}
function onChangeAppSelect(evt) {
var isOther = jxl.getValue("uiApp") == "other";
var i = toShowIfOther.length || 0;
while (i--) {
jxl.display(toShowIfOther[i], isOther);
}
if (addressTemplates) {
updateAddress();
}
}
function onChangeSchemeSelect(evt) {
var isUserdef = jxl.getValue("uiScheme") == "userdef";
jxl.display("uiUserdefDiv", isUserdef);
if (addressTemplates) {
updateAddress();
}
}
jxl.addEventHandler("uiApp", "change", onChangeAppSelect);
jxl.addEventHandler("uiScheme", "change", onChangeSchemeSelect);
if (addressTemplates) {
jxl.addEventHandler("uiLandevice", "change", updateAddress);
jxl.addEventHandler("uiUserdefscheme", "change", updateAddress);
jxl.addEventHandler("uiPort", "keyup", updateAddress);
jxl.addEventHandler("uiURLPath", "keyup", updateAddress);
jxl.addEventHandler("uiPort", "change", updateAddress);
jxl.addEventHandler("uiURLPath", "change", updateAddress);
}
if (!addressTemplates) {
jxl.hide("uiAddressBox");
}
onChangeAppSelect();
onChangeSchemeSelect();
}
ready.onReady(initChangeHandler);
ready.onReady(ajaxValidation());
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua
html.input{type="hidden", name="edit", value=box.get.edit or box.post.edit or ""}.write()
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
?>
<p>
{?4617:864?}
</p>
<hr>
<p>
{?4617:906?}
</p>
<?lua write_landevice_select() ?>
<?lua write_app_select() ?>
<div class="showif_other">
<div class="formular">
<label for="uiAppname">{?4617:97?}
</label>
<input type="text" name="appname" id="uiAppname" value="<?lua write_appname() ?>">
</div>
<?lua write_scheme_select() ?>
<div class="formular">
<label for="uiPort">{?4617:498?}
</label>
<input type="text" name="Port" id="uiPort" value="<?lua write_port() ?>">
</div>
</div>
<div class="formular widetext">
<label for="uiURLPath">{?4617:574?}
</label>
<input type="text" name="URLPath" id="uiURLPath" value="<?lua write_path() ?>">
</div>
<br>
<div class="formular" id="uiAddressBox">
<span class="label">{?4617:110?}</span>
<span id="uiAddress" class="output"></span>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
