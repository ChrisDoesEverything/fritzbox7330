<?lua
--[[
Datei Name: trafficprio_edit.lua
Datei Beschreibung:
]]
g_page_type = "all"
g_menu_active_page = "/internet/trafficprio.lua"
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("cmtable")
require("js")
require("ip")
g_default_dev = "0.0.0.0"
local g_txt_all = "{?580:194?}"
g_realtime = "1"
g_prio = "2"
g_background = "4"
g_remoteData = {}
function read_box_values()
local table_index = "get"
if (box.post.type or box.post.user_id) then
table_index = "post"
end
g_remoteData.is_new = false
g_remoteData.user_id = ""
if (box[table_index].user_id) then
g_remoteData.user_id = box[table_index].user_id
g_remoteData.type = box.query("trafficprio:settings/" .. g_remoteData.user_id .. "/type")
else
g_remoteData.is_new = true
g_remoteData.type = box[table_index].type
if (g_remoteData.type == nil or g_remoteData.type == "") then
g_remoteData.type = g_realtime
end
g_remoteData.user_id = box.query("trafficprio:settings/user/newid")
end
g_remoteData.rule_list = general.listquery("trafficprio:settings/user/list(type,ip,profile)")
g_remoteData.device_list = general.listquery("landevice:settings/landevice/list(ip,name)")
g_remoteData.appl_list = general.listquery("netapp:settings/profile/list(name,internal)")
g_remoteData.appl_list_associative = {}
for index,value in ipairs(g_remoteData.appl_list) do
g_remoteData.appl_list_associative[value._node] = value
end
g_remoteData.ip = ip.quad2table(g_default_dev)
local queried_ip = box.query("trafficprio:settings/" .. g_remoteData.user_id .. "/ip")
if (queried_ip ~= nil and queried_ip ~= "") then
g_remoteData.ip = ip.quad2table(queried_ip)
end
g_remoteData.profile = g_txt_all
local queried_profile = box.query("trafficprio:settings/" .. g_remoteData.user_id .. "/profile")
if (queried_profile ~= nil and queried_profile ~= "") then
g_remoteData.profile = queried_profile
end
g_page_title = "{?580:246?}"
if (g_remoteData.type == g_prio) then
g_page_title = "{?580:94?}"
elseif (g_remoteData.type == g_background) then
g_page_title = "{?580:180?}"
end
end
read_box_values()
g_page_help = "hilfe_internet_prio_neue-regel_echtzeit.html"
if (g_remoteData.type == g_prio) then
g_page_help = "hilfe_internet_prio_neue-regel_prior.html"
elseif (g_remoteData.type == g_background) then
g_page_help = "hilfe_internet_prio_neue-regel_hintergr.html"
end
function get_ip()
local ip_string = g_default_dev
if (box.post.is_new == "false") then
ip_string = get_ip_string(g_remoteData.ip)
end
if (box.post.devices ~= nil) then
ip_string = box.post.devices
end
if (ip_string == 'manuell') then
ip_string = ip.read_from_post("ip")
end
return ip_string
end
function refill_user_input()
if (box.post) then
g_remoteData.ip = ip.quad2table(get_ip())
g_remoteData.profile = g_txt_all
local appl_table = g_remoteData.appl_list_associative[box.post.appl]
if (appl_table) then
g_remoteData.profile = appl_table.name
end
g_remoteData.type = box.post.type
g_remoteData.is_new = box.post.is_new ~= "false"
end
end
g_val = {
prog = [[
if __callfunc(uiAppl/appl, is_not_appl) then
const_error(uiAppl/appl, outofrange, appl_error_txt)
end
if __value_empty(uiAppl/appl) then
not_empty(uiDevices/devices, device_error_txt)
not_equals(uiDevices/devices, ]]..g_default_dev..[[, device_error_txt)
end
if __callfunc(uiAppl/appl, is_internal_appl) then
if __value_not_empty(uiDevices/devices) then
if __value_not_equal(uiDevices/devices, ]]..g_default_dev..[[) then
const_error(uiDevices/devices, outofrange, device_error_txt)
end
end
end
if __callfunc(uiAppl/appl, is_not_internal_appl) then
if __value_not_empty(uiDevices/devices) then
if __value_equal(uiDevices/devices, manuell) then
ipv4(uiIp/ip, ip_error_txt)
end
if __value_not_equal(uiDevices/devices, manuell) then
char_range_regex(uiDevices/devices, ipv4, device_error_txt)
end
end
end
if __callfunc(uiAppl/appl, rule_exists) then
const_error(uiAppl/appl, equalerr, appl_error_txt)
end
]]
}
function rule_exists(appl)
local user_list = g_remoteData.rule_list
local appl_table = g_remoteData.appl_list_associative[box.post[appl]]
local posted_ip = get_ip()
local appl_name = ""
if (appl_table) then
appl_name = appl_table.name
end
local ip_string = get_ip_string(g_remoteData.ip)
for index,value in ipairs(user_list) do
if (value.ip == posted_ip and value.profile == appl_name and value.type == box.post.type and g_remoteData.profile ~= appl_name) then
return true
end
end
return false
end
function is_not_appl(appl)
if (appl and box.post and box.post[appl] ~= "") then
return g_remoteData.appl_list_associative[box.post[appl]] == nil
end
return false
end
function is_internal_appl(appl)
if (appl and box.post[appl] ~= "") then
return g_remoteData.appl_list_associative[box.post[appl]].internal == "1"
end
return false
end
function is_not_internal_appl(appl)
if (appl and box.post[appl] ~= "") then
return g_remoteData.appl_list_associative[box.post[appl]].internal == "0"
elseif (box.post[appl] == "") then
return true
end
return false
end
local msg_dev=[[{?580:662?}]]
val.msg.device_error_txt = {
[val.ret.empty] = msg_dev,
[val.ret.notfound] = msg_dev,
[val.ret.format] = msg_dev,
[val.ret.outofrange] = msg_dev,
[val.ret.equalerr] = [[{?580:751?}]],
}
val.msg.appl_error_txt = {
[val.ret.outofrange] = [[{?580:537?}]],
[val.ret.equalerr] = [[{?580:69?}]]
}
val.msg.ip_error_txt = {
[val.ret.empty] = [[{?580:855?}]],
[val.ret.notfound] = [[{?580:395?}]],
[val.ret.format] = [[{?580:122?}]],
[val.ret.outofrange] = [[{?580:56?}]],
[val.ret.outofnet] = [[{?580:593?}]],
[val.ret.thenet] = [[{?580:53?}]],
[val.ret.broadcast] = [[{?580:950?}]],
[val.ret.thebox] = [[{?580:27?}]],
[val.ret.unsized] = [[{?580:334?}]]
}
function get_disabled()
local disabled = [[disabled = "disabled"]]
if (g_remoteData.is_new) then
disabled = ""
end
return disabled
end
function get_disabled_node()
local disabled = [[disableNode]]
if (g_remoteData.is_new) then
disabled = ""
end
return disabled
end
function get_ip_string(ip_table)
return ip_table[1].."."..ip_table[2].."."..ip_table[3].."."..ip_table[4]
end
function get_client_ip4_adress()
if string.find(tostring(box.glob.clientipaddress), val.pr.ipv4.pat) then
return tostring(box.glob.clientipaddress)
end
return ""
end
function get_device_list_extended()
local extended_list = {}
local all_device = {
ip = g_default_dev,
name = "{?580:67?}"
}
table.insert(extended_list, all_device)
for index,value in ipairs(g_remoteData.device_list) do
table.insert(extended_list, value)
end
local manual_device = {
ip = "manuell",
name = "{?580:634?}"
}
table.insert(extended_list, manual_device)
return extended_list
end
function write_device_list()
for index,value in ipairs(get_device_list_extended()) do
if (value.ip ~= "") then
local selected = ""
if (value.ip == get_ip_string(g_remoteData.ip) or value.ip == box.post.devices) then
selected = "selected"
end
box.out([[<option ]]..selected..[[ value="]]..box.tohtml(value.ip)..[[">]]..box.tohtml(value.name)..[[</option>]])
end
end
end
function write_input_block()
local disabled = "disabled"
if (g_remoteData.is_new) then
disabled = ""
end
local str=[[
<div id="uiIpbox" class="]]..get_disabled_node()..[[" ]]..disabled..[[ >
<label for="uiIp0">{?580:926?}</label>
<input type="text" size="3" maxlength="3" id="uiIp0" name="ip0" value="]]..box.tohtml(g_remoteData.ip[1])..[[" ]]..val.get_attrs(g_val, 'uiIp0', 'IpErr')..[[ /> .
<input type="text" size="3" maxlength="3" id="uiIp1" name="ip1" value="]]..box.tohtml(g_remoteData.ip[2])..[[" ]]..val.get_attrs(g_val, 'uiIp1', 'IpErr')..[[ /> .
<input type="text" size="3" maxlength="3" id="uiIp2" name="ip2" value="]]..box.tohtml(g_remoteData.ip[3])..[[" ]]..val.get_attrs(g_val, 'uiIp2', 'IpErr')..[[ /> .
<input type="text" size="3" maxlength="3" id="uiIp3" name="ip3" value="]]..box.tohtml(g_remoteData.ip[4])..[[" ]]..val.get_attrs(g_val, 'uiIp3', 'IpErr')..[[ />
</div>]]
box.out(str)
end
function get_appl_list_extended()
local extended_list = {}
local all_appl = {
_node = "",
name = g_txt_all
}
table.insert(extended_list, all_appl)
for index,value in ipairs(g_remoteData.appl_list) do
table.insert(extended_list, value)
end
return extended_list
end
function write_appl_list()
for index,value in ipairs(get_appl_list_extended()) do
local selected = ""
if (g_remoteData.profile == value.name) then
selected = "selected"
end
box.out([[<option ]]..selected..[[ value="]]..box.tohtml(value._node)..[[">]]..box.tohtml(value.name)..[[</option>]])
end
end
if next(box.post) then
if box.post.btn_cancel then
http.redirect(href.get('/internet/trafficprio.lua'))
elseif box.post.apply then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
if (box.post.type and box.post.type ~= "") then
local appl_name = ""
if (g_remoteData.appl_list_associative[box.post.appl]) then
appl_name = g_remoteData.appl_list_associative[box.post.appl].name
end
cmtable.add_var(ctlmgr_save, "trafficprio:settings/" .. g_remoteData.user_id .. "/ip", get_ip())
cmtable.add_var(ctlmgr_save, "trafficprio:settings/" .. g_remoteData.user_id .. "/type", box.post.type)
cmtable.add_var(ctlmgr_save, "trafficprio:settings/" .. g_remoteData.user_id .. "/profile", appl_name)
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
box.out(general.create_error_div(err, msg))
refill_user_input()
else
http.redirect(href.get('/internet/trafficprio.lua'))
end
else
refill_user_input()
end
else
refill_user_input()
end
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.margin_and_height {
margin-right: 6px;
margin-bottom: 10px;
}
.wide_select select {
width: 260px;
}
</style>
<?include "templates/page_head.html" ?>
<form id="MainForm" class="close" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="formular">
<p>{?580:985?}</p>
<div class="wide_select">
<select class="floatleft margin_and_height <?lua box.out(get_disabled_node()) ?>" size="1" id="uiDevices" name="devices" onchange="onChangeIpName(value)" <?lua box.out(get_disabled()) ?>>
<?lua write_device_list() ?>
</select>
<?lua val.write_html_msg(g_val, "uiDevices")?>
<?lua write_input_block() ?>
<?lua val.write_html_msg(g_val, "uiIp0", "uiIp1", "uiIp2", "uiIp3")?>
</div>
<div class="clear_float wide_select">
<p>{?580:699?}</p>
<select size="1" id="uiAppl" name="appl" onchange="onApplChange(this)" ><?lua write_appl_list() ?></select>
<?lua val.write_html_msg(g_val, "cmd_vorn", "uiAppl")?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" id="uiType" name="type" value="<?lua box.html(g_remoteData.type)?>">
<input type="hidden" id="uiUserId" name="user_id" value="<?lua box.html(g_remoteData.user_id)?>">
<input type="hidden" id="uiIsNew" name="is_new" value="<?lua box.out(g_remoteData.is_new)?>">
<button type="submit" name="apply" id="uiBtnOK">{?txtApplyOk?}</button>
<button type="submit" name="btn_cancel" id="uiBtnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
}
var gApplList = <?lua box.out(js.table(g_remoteData.appl_list_associative)) ?>;
function ruleExists(applId) {
var profile = "<?lua box.out(g_remoteData.profile) ?>";
var userList = <?lua box.out(js.table(g_remoteData.rule_list)) ?>;
var appl_name = "";
if (gApplList[jxl.getValue("uiAppl")])
appl_name = gApplList[jxl.getValue("uiAppl")].name;
var chosenIp = jxl.getValue("uiDevices");
if (chosenIp == 'manuell') {
chosenIp = ip.partsToQuad("uiIp");
}
for (var i = 0; i < userList.length; i++){
var appl = userList[i];
if (appl.ip == chosenIp && appl.profile == appl_name && appl.type == jxl.getValue("uiType") && profile != appl_name){
return true;
}
}
return false;
}
function isNotAppl(appl) {
var applValue = jxl.getValue(appl);
return !(applValue == "" || gApplList[applValue] != null);
}
function isNotInternalAppl(appl) {
var applValue = jxl.getValue(appl);
return applValue == "" || applValue != "" && gApplList[applValue] && gApplList[applValue].internal == "0";
}
function isInternalAppl(appl) {
var applValue = jxl.getValue(appl);
return applValue != "" && gApplList[applValue] && gApplList[applValue].internal == "1";
}
var gDefaultDev = "<?lua box.out(g_default_dev) ?>";
function onChangeIpName(value) {
var ipTable = ["","","",""];
var isDisabled;
var isVisible;
if (value == "manuell"){
var ip = <?lua box.out(js.table(g_remoteData.ip)) ?>;
if (!ip || ip == "er" || ip[0] == "" || ip[0] == "0") {
ip = "<?lua box.out(get_client_ip4_adress()) ?>".split(".");
}
ipTable = ip;
isDisabled = false;
isVisible = true;
jxl.enableWithFocus("uiIp0");
jxl.select("uiIp0");
}
else if (value == gDefaultDev){
ipTable = ["","","",""];
isDisabled = false;
isVisible = false;
}
else {
ipTable = value.split(".");
isDisabled = true;
isVisible = true;
}
jxl.display("uiIpbox", isVisible);
//jxl.disableNode("uiIpbox", isDisabled, true);
for (var i = 0; i < ipTable.length; i++)
{
jxl.setValue("uiIp"+i,ipTable[i]);
jxl.disableNode("uiIp"+i, isDisabled);
}
if (<?lua box.out(g_remoteData.is_new == false) ?>)
{
jxl.disableNode("uiDevices", true);
jxl.disableNode("uiIpbox", true);
//jxl.disableNode("uiIp", true);
}
}
function onApplChange(appl) {
if (<?lua box.out(g_remoteData.is_new)?>)
{
if (isInternalAppl(appl))
{
jxl.setSelection("uiDevices", gDefaultDev);
onChangeIpName(gDefaultDev);
jxl.disableNode("uiDevices", true);
}
else
{
jxl.disableNode("uiDevices", false);
}
}
}
function init() {
fc.init("uiIpbox", 3, 'ip');
onChangeIpName(jxl.getValue("uiDevices"));
}
ready.onReady(val.init(onNumEditSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
