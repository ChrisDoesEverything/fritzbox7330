<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_internet_myfritz_freigaben.html"
dofile("../templates/global_lua.lua")
g_err = {}
require"general"
require"utf8"
require"html"
require"myfritz_access"
require"dump"
require("cmtable")
local function split_value(value)
local t = (value or ""):split(":")
return {device_uid = t[1], service_node = t[2]}
end
local function build_value(device, service)
return (device.UID or "") .. ":" .. (service._node or "")
end
local function build_address(device, service, myfritz_url)
local address = {}
local dyndnslabel = device.dyndnslabel or ""
if not myfritz_url or myfritz_url == "" or dyndnslabel == "" then
return [[{?7947:123?}]]
else
myfritz_url = dyndnslabel .. "." .. myfritz_url
local port = tonumber(service.Port)
if port then
port = ":" .. port
end
address = {
service.Scheme or "",
myfritz_url,
port,
service.URLPath or ""
}
end
return table.concat(address, "")
end
local function get_btn(which, device, service)
local btn = html.button{type="submit", class="icon", name=which}
btn.value = build_value(device, service)
local img = html.img()
if which == 'edit' then
img.src = "/css/default/images/bearbeiten.gif"
btn.title = [[{?txtIconBtnEdit?}]]
elseif which == 'delete' then
img.src = "/css/default/images/loeschen.gif"
btn.title = [[{?txtIconBtnDelete?}]]
btn.onclick="return OnDelete();"
end
btn.add(img)
return btn
end
local function get_enabled_checkbox(device, service)
return html.input{
type = "checkbox", name = "enabled_" .. build_value(device, service),
checked = service.Enabled == "1"
}
end
function write_alert_ipv4forwarding_warning_js()
local result = [[]]
if box.get.ipv4ForwardingWarning == "0" then
result = [[{?7947:4?}]]
elseif box.get.ipv4ForwardingWarning == "2" then
result = [[{?7947:832?}]]
end
box.js(result)
end
if box.post.cancel then
http.redirect(box.glob.script)
end
if box.post.edit then
http.redirect(
href.get("/internet/myfritz_device_edit.lua", http.url_param("edit", box.post.edit))
)
end
if box.post.delete then
local value = split_value(box.post.delete)
if value.device_uid and value.service_node then
local webvar = "myfritzdevice:command/device[" .. value.device_uid .. "]/services/"
local saveset = {}
cmtable.add_var(saveset, webvar .. value.service_node, "delete")
webvar = webvar:gsub(":command/", ":settings/")
local cnt_services = tonumber(box.query(webvar .. "entry/count")) or 0
if cnt_services <= 1 then
local lan_uid = box.query("myfritzdevice:settings/device[" .. value.device_uid .. "]/landevice_UID")
if lan_uid then
webvar = "landevice:settings/landevice[" .. lan_uid .. "]/myfritz_enabled"
cmtable.add_var(saveset, webvar, "0")
end
end
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(box.glob.script)
end
end
end
if box.post.apply then
local saveset = {}
local list = myfritz_access.read_list()
local webvar = "myfritzdevice:settings/device[%s]/services/%s/Enabled"
for i, device in ipairs(list) do
for j, service in ipairs(device.services) do
local val = build_value(device, service)
cmtable.add_var(saveset,
webvar:format(device.UID, service._node),
box.post["enabled_" .. val] and "1" or "0"
)
end
end
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(box.glob.script)
end
end
local list, list_length = myfritz_access.read_list("sorted")
function write_list()
local myfritz_url = box.query("jasonii:settings/dyndnsname")
for i, device in ipairs(list) do
local devname = myfritz_access.get_name(device)
for j, service in ipairs(device.services) do
html.tr{
html.td{class="iconrow", get_enabled_checkbox(device, service)},
html.td{devname},
html.td{class="address", build_address(device, service, myfritz_url)},
html.td{service.Name or ""},
html.td{class="btncolumn",
get_btn("edit", device, service),
get_btn("delete", device, service)
}
}.write()
end
end
if list_length == 0 then
html.tr{class="emptylist",
html.td{colspan=5,
[[{?7947:334?}]]
}
}.write()
end
end
function write_btnhide_css()
if list_length == 0 then
box.out([[.hideif_empty ]])
else
box.out([[.showif_empty ]])
end
box.out([[{display: none;}]])
end
function write_error()
if g_err.code and g_err.code ~= 0 then
require"general"
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
td.address {
width: 300px;
}
p.pathdisplay {
white-space:nowrap;
overflow:hidden;
text-overflow:ellipsis;
}
<?lua write_btnhide_css() ?>
</style>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort = sorter();
function alertOnLoad() {
var warning = "<?lua write_alert_ipv4forwarding_warning_js() ?>";
if (warning) {
alert(warning);
}
}
function OnDelete()
{
if (!confirm("{?7947:468?}"))
return false
return true
}
function initTableSorter() {
sort.init("uiDevices");
sort.sort_table_again(0);
}
ready.onReady(initTableSorter);
ready.onReady(alertOnLoad);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_error() ?>
<p>
{?7947:665?}
</p>
<hr>
<table id="uiDevices" class="zebra">
<tr class="thead">
<th class="iconrow">{?7947:840?}</th>
<th class="sortable">{?7947:186?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?7947:67?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?7947:498?}<span class="sort_no">&nbsp;</span></th>
<th class="btncolumn"></th>
</tr>
<?lua write_list() ?>
</table>
<div class="btn_form">
<button type="submit" name="edit" value="new">
{?7947:285?}
</button>
</div>
<div id="btn_form_foot">
<button class="showif_empty" type="submit" name="refresh">{?txtRefresh?}</button>
<button class="hideif_empty" type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button class="hideif_empty" type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
