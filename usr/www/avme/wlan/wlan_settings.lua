<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_wlan_funknetz.html"
dofile("../templates/global_lua.lua")
require("http")
require("href")
require("menu")
if not menu.check_page("wlan", [[/wlan/wlan_settings.lua]]) then
http.redirect(href.get([[/home/home.lua]]))
box.end_page()
end
g_page_needs_js=true
require("general")
require("cmtable")
require("val")
require("ip")
require("string")
require("net_devices")
g_dev = {}
g_dev.opmode = ""
g_dev.wlan_count = 0
g_back_to_page = http.get_back_to_page( "/wlan/wlan_settings.lua" )
g_new_device_by_mac=""
g_errmsg = nil
g_active = "0"
g_hidden_ssid = "0"
g_ssid = ""
g_isolation = "0"
g_dev.macfilter = "0"
g_fritz_app_enabled = "0"
g_active_scnd = "0"
g_ssid_scnd = ""
g_is_double_wlan = false
g_active = box.query("wlan:settings/ap_enabled")
g_active_scnd = "0"
g_row_count = 0
g_table_html = ""
if config.WLAN.is_double_wlan then
g_is_double_wlan = true
g_active_scnd = box.query("wlan:settings/ap_enabled_scnd")
end
g_val = {
prog = [[
if __checked(uiView_Active/active) then
not_empty(uiView_SSID/SSID, ssid_error_txt)
char_range(uiView_SSID/SSID, 32, 126, ssid_error_txt)
no_lead_char(uiView_SSID/SSID,32,ssid_error_txt)
no_end_char(uiView_SSID/SSID,32,ssid_error_txt)
end
]]
}
if (g_is_double_wlan and general.is_expert()) then
g_val.prog = [[
if __checked(uiView_Active_24/active_24) then
not_empty(uiView_SSID_24/SSID_24, ssid_error_txt)
char_range(uiView_SSID_24/SSID_24, 32, 126, ssid_error_txt)
no_lead_char(uiView_SSID_24/SSID_24,32,ssid_error_txt)
no_end_char(uiView_SSID_24/SSID_24,32,ssid_error_txt)
end
if __checked(uiView_Active_5/active_5) then
not_empty(uiView_SSID_5/SSID_5, ssid_error_txt)
char_range(uiView_SSID_5/SSID_5, 32, 126, ssid_error_txt)
no_lead_char(uiView_SSID_5/SSID_5,32,ssid_error_txt)
no_end_char(uiView_SSID_5/SSID_5,32,ssid_error_txt)
end
]]
end
val.msg.ssid_error_txt = {
[val.ret.empty] = [[{?1706:539?}]],
[val.ret.toolong] = [[{?1706:725?}]],
[val.ret.outofrange] = [[{?1706:212?}]],
[val.ret.leadchar] = [[{?1706:699?}]],
[val.ret.endchar] = [[{?1706:877?}]]
}
function read_box_values()
g_dev = net_devices.g_list
g_dev.macfilter = box.query("wlan:settings/is_macfilter_active")
g_dev.opmode = box.query("box:settings/opmode")
g_dev.wlan_count = tonumber(box.query("wlan:settings/wlanlist/count")) or 0
g_active = box.query("wlan:settings/ap_enabled")
g_hidden_ssid = box.query("wlan:settings/hidden_ssid")
g_ssid = box.query("wlan:settings/ssid")
g_isolation = box.query("wlan:settings/user_isolation")
g_fritz_app_enabled = "0"
if g_is_double_wlan then
g_active_scnd = box.query("wlan:settings/ap_enabled_scnd")
if (general.is_expert()) then
g_ssid_scnd = box.query("wlan:settings/ssid_scnd")
else
if (g_active_scnd=="1") then
g_ssid_scnd = box.query("wlan:settings/ssid_scnd")
if (g_active=="0") then
g_ssid = g_ssid_scnd
end
else
g_ssid_scnd = g_ssid
end
end
end
end
function refill_user_input_from_post()
g_dev = net_devices.g_list
g_dev.opmode = box.query("box:settings/opmode")
g_dev.wlan_count = tonumber(box.query("wlan:settings/wlanlist/count")) or 0
g_active = "0"
if g_is_double_wlan then
if (general.is_expert()) then
if (box.post.active_24) then
g_active = "1"
end
else
if (box.post.active) then
g_active = "1"
end
end
else
if (box.post.active) then
g_active = "1"
end
end
g_hidden_ssid = "1"
if (box.post.hidden_ssid) then
g_hidden_ssid = "0"
end
g_ssid=box.query("wlan:settings/ssid")
if g_is_double_wlan then
if (general.is_expert()) then
if (box.post.SSID_24) then
g_ssid = box.post.SSID_24
end
else
if (box.post.SSID) then
g_ssid = box.post.SSID
end
end
else
if (box.post.SSID) then
g_ssid = box.post.SSID
end
end
g_fritz_app_enabled = "0"
g_active_scnd= "0"
if g_is_double_wlan then
if (not (general.is_expert())) then
--g_active_scnd = box.query("wlan:settings/ap_enabled_scnd")
g_active_scnd = g_active
elseif (box.post.active_5) then
g_active_scnd = "1"
end
g_ssid_scnd = box.query("wlan:settings/ssid_scnd")
if (box.post.SSID_5) then
g_ssid_scnd = box.post.SSID_5
if (not (general.is_expert())) then
g_ssid_scnd = g_ssid
end
end
end
if (g_active=="0" and g_active_scnd=="0") then
g_hidden_ssid = box.query("wlan:settings/hidden_ssid")
g_ssid = box.query("wlan:settings/ssid")
g_isolation = box.query("wlan:settings/user_isolation")
end
end
function refill_user_input_from_get()
g_active = "0"
if g_is_double_wlan then
if (general.is_expert()) then
if (box.get.active_24) then
g_active = "1"
end
else
if (box.get.active) then
g_active = "1"
end
end
else
if (box.get.active) then
g_active = "1"
end
end
g_hidden_ssid = "1"
if (box.get.hidden_ssid) then
g_hidden_ssid = "0"
end
g_ssid=box.query("wlan:settings/ssid")
if g_is_double_wlan then
if (general.is_expert()) then
if (box.get.SSID_24) then
g_ssid = box.get.SSID_24
end
else
if (box.get.SSID) then
g_ssid = box.get.SSID
end
end
else
if (box.get.SSID) then
g_ssid = box.get.SSID
end
end
g_fritz_app_enabled = "0"
g_active_scnd= "0"
if g_is_double_wlan then
if (box.get.active_5) then
g_active_scnd = "1"
elseif (not (general.is_expert())) then
g_active_scnd = box.query("wlan:settings/ap_enabled_scnd")
end
g_ssid_scnd = box.query("wlan:settings/ssid_scnd")
if (box.get.SSID_5) then
g_ssid_scnd = box.get.SSID_5
elseif (not (general.is_expert())) then
end
end
end
function check_param(name)
local s=string.find(name,"_i$")
if (s) then
return false
end
if (name=="add_mac") then
return false
end
if (name=="macstr") then
return false
end
return true
end
if next(box.post) then
if box.post.validate == "apply" then
local valresult, answer = val.ajax_validate(g_val)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
refill_user_input_from_post()
local saveset = {}
if general.is_expert() then
cmtable.add_var(saveset, "wlan:settings/ap_enabled" , g_active )
else
cmtable.add_var(saveset, "wlan:settings/wlan_enable" , g_active )
end
cmtable.add_var(saveset, "wlan:settings/hidden_ssid" , g_hidden_ssid )
cmtable.add_var(saveset, "wlan:settings/ssid" , g_ssid )
if (g_is_double_wlan) then
if general.is_expert() then
cmtable.add_var(saveset, "wlan:settings/ap_enabled_scnd" , g_active_scnd )
end
cmtable.add_var(saveset, "wlan:settings/ssid_scnd" , g_ssid_scnd )
end
local err=0
err, g_errmsg = box.set_config(saveset)
if err==0 then
if box.glob.script ~= g_back_to_page then
http.redirect(href.get(g_back_to_page))
end
end
elseif box.post.edit and box.post.edit~="" then
http.redirect(href.get('/net/edit_device.lua','dev='..box.post.edit, 'back_to_page='..box.glob.script))
read_box_values()
refill_user_input_from_get()
elseif box.post.feedback and box.post.feedback~="" then
g_dev=net_devices.g_list
local idx,elem = net_devices.find_dev_by_uid(g_dev, box.post.feedback)
if not(elem) then
idx,elem = net_devices.find_dev_by_node(g_dev, box.post.feedback)
end
if not(elem) then
idx,elem = net_devices.find_dev_by_name(g_dev, box.post.feedback)
end
if idx and elem then
http.redirect(href.get('/wlan/feedback.lua','devname='..net_devices.get_name(elem),'mac='..elem.mac, 'back_to_page='..box.glob.script))
end
read_box_values()
refill_user_input_from_get()
elseif box.post.delete and box.post.delete~="" then
g_dev=net_devices.g_list
g_dev.macfilter = box.query("wlan:settings/is_macfilter_active")
g_dev.opmode = box.query("box:settings/opmode")
g_dev.wlan_count = tonumber(box.query("wlan:settings/wlanlist/count")) or 0
local idx,elem = net_devices.find_dev_by_uid(g_dev, box.post.delete)
if not(elem) then
idx,elem = net_devices.find_dev_by_node(g_dev, box.post.delete)
end
if not(elem) then
idx,elem = net_devices.find_dev_by_name(g_dev, box.post.delete)
end
if idx and elem and elem.type~="user" and elem.deleteable ~= "0" and
not(g_dev.macfilter=="1" and elem.wlan=="1" and g_dev.wlan_count<2) and
not(g_dev.macfilter=="0" and elem.wlan=="1" and elem.active=="1") then
local ctlmgr_del={}
cmtable.add_var(ctlmgr_del, "landevice:command/landevice["..elem.UID.."]" , "delete")
if elem.wlan=="1" and elem.wlan_node then
cmtable.add_var(ctlmgr_del, "wlan:command/"..elem.wlan_node , "delete")
end
local err,msg = box.set_config(ctlmgr_del)
if err ~= 0 then
local criterr = general.create_error_div(err,msg,[[{?1706:29?}]])
box.out(criterr)
end
net_devices.InitNetList()
refill_user_input_from_post()
end
elseif box.post.cancel or box.post.refresh_list or box.post.btn_refresh then
http.redirect(href.get(g_back_to_page))
return
end
else
read_box_values()
end
g_new_device_by_mac=""
if box.get then
if box.get.load_again then
refill_user_input_from_get()
end
end
function init()
if (g_new_device_by_mac~="") then
net_devices.check_and_add(g_dev, g_new_device_by_mac)
end
if (g_dev) then
table.sort(g_dev, net_devices.compareByQuality)
end
g_table_html, g_row_count = net_devices.create_known_wlandevices_table("receive", "name", "ip", "mac", "rate", "properties", "feedback", "edit_btn", "del_btn")
end
function show_both_qrcode()
return g_is_double_wlan and general.is_expert() and g_active == "1" and g_active_scnd == "1" and g_ssid_scnd ~= g_ssid
end
function get_expert_features()
if (not general.is_expert()) then
return [[display:none]]
end
return [[]]
end
function write_expert_features()
box.out(get_expert_features())
end
function write_non_expert_features()
if (general.is_expert()) then
box.out([[display:none]])
end
end
function write_active(which)
if box.query("wlan:settings/wlan_config_status") =="fail" then
box.out([[ disabled ]])
return
end
if which=="both" then
if g_active=="1" or g_active_scnd=="1" then
box.out([[checked]])
end
else
if g_active=="1" then
box.out([[checked]])
end
end
end
function write_active_scnd()
if box.query("wlan:settings/wlan_config_status") =="fail" then
box.out([[ disabled ]])
return
end
if g_active_scnd=="1" then
box.out([[checked]])
end
end
function write_hidden()
if g_hidden_ssid=="0" then
box.out([[checked]])
end
end
function write_FritzApp_active()
if g_fritz_app_enabled=="1" then
box.out([[checked]])
end
end
function write_wlan_failed()
if box.query("wlan:settings/wlan_config_status") =="fail" then
box.out([[ disableNode ]])
end
end
function write_known_wlandevices()
box.out(g_table_html)
end
init()
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/qrcode.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<style type="text/css">
.formular div.row {
padding:2px 0px;
}
.formular div.tborder {
padding:5px;
}
.formular div.tborder2 {
padding:5px;
border-left:1px solid #C6C7BE;
border-right:1px solid #C6C7BE;
border-bottom:1px solid #C6C7BE;
border-top:none;
}
div.tborder {
padding:5px;
}
div.tborder2 {
padding:5px;
border-left:1px solid #C6C7BE;
border-right:1px solid #C6C7BE;
border-bottom:1px solid #C6C7BE;
border-top:none;
}
label {
width:250px;
}
.formular label {
width:250px;
}
.formular .formular label {
width:250px;
}
.rightBtn .left_block {
text-align: left;
float:none;
}
.rightBtn .left_block p{
text-align: left;
}
.rightBtn .left_block input{
width:auto;
}
.wide label {
width:auto;
}
#uiAccessControl {
text-align: right;
padding: 3px;
}
#uiAccessControl span {
margin-left: 20px;
}
</style>
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
var g_active =<?lua box.out(tostring(g_active)=="1") ?>;
var g_active_scnd =<?lua box.out(tostring(g_active_scnd)=="1") ?>;
var g_isDoubleWlan =<?lua box.out(tostring(g_is_double_wlan)) ?>;
var g_expertMode =<?lua box.out(tostring(general.is_expert())) ?>;
var g_any_wlan =<?lua box.out(net_devices.AnyWlanDevice(g_dev))?>;
function checkWlanDelete(devType, wlan, deleteable, devName, active, wdsRepeater, kisi)
{
if (wdsRepeater=="1" && active=="1")
{
alert('{?3019:206?}');
return false;
}
if (wlan=="1" && <?lua box.out(tostring(g_dev.macfilter=="1")) ?> && <?lua box.out(tostring(g_dev.wlan_count<2)) ?>)
{
alert('{?3019:4394?}');
return false;
}
if (<?lua box.out(tostring(g_dev.macfilter=="0")) ?> && wlan=="1" && active=="1")
{
alert("{?3019:243?}");
return false;
}
if (wlan=="1" && "<?lua box.out(g_dev.macfilter=='1') ?>")
{
if (!confirm("{?1706:382?}"))
return false;
}
if (deleteable=="1")
if(!confirm(jxl.sprintf('{?3019:655?}\n{?3019:668?}',devName)))
return false;
if (deleteable=="0")
{
alert('{?3019:910?}');
return false;
}
return true;
}
function activate_areas()
{
if (g_isDoubleWlan)
{
jxl.disableNode("uiOption_24",!g_active);
jxl.disableNode("uiOption_5",!g_active_scnd);
jxl.disableNode("uiOption",!g_active && !g_active_scnd);
jxl.disableNode("uiExpertFeatures",!g_active && !g_active_scnd);
jxl.disableNode("uiAccessControl",!g_active && !g_active_scnd);
jxl.disableNode("uiFritzApp",!g_active && !g_active_scnd);
}
else
{
jxl.disableNode("uiOption",!g_active);
jxl.disableNode("uiAccessControl",!g_active);
jxl.disableNode("uiFritzApp",!g_active);
}
}
function uiDoOnMainFormSubmit()
{
return true;
}
function OnActivated(which,checked)
{
switch (which)
{
case "24":
g_active=checked;
break;
case "5":
g_active_scnd=checked;
break;
case "both":
g_active=checked;
g_active_scnd=checked;
break;
}
activate_areas()
}
function init()
{
activate_areas();
if (!isCanvasSupported()){
jxl.display("uiViewQRCode", false);
return;
}
<?lua
local encryption = box.query("wlan:settings/encryption")
local qr_key = ""
if encryption=="0" then
qr_key = ""
elseif encryption=="1" then
qr_key = net_devices.calc_ascii_key(box.query("key_value"..box.query("wlan:settings/key_id")))
else
qr_key = box.query("wlan:settings/pskvalue")
end
local ssid = g_ssid
if g_active ~= "1" then
ssid = g_ssid_scnd
end
box.out([[updateQRCode("qrcode", "]], box.tojs(net_devices.get_wlan_qr_string(ssid, encryption, qr_key)), [[");]])
if show_both_qrcode() then
box.out([[updateQRCode("qrcodeScnd", "]], box.tojs(net_devices.get_wlan_qr_string(g_ssid_scnd, encryption, qr_key)), [[");]])
end
?>
}
function initTableSorter() {
sort.init("uiWlanDevs");
sort.sort_table(0);
}
ready.onReady(initTableSorter);
<?lua
net_devices.write_showPrintView_func("main")
?>
ready.onReady(ajaxValidation({
okCallback: uiDoOnMainFormSubmit
}));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div id="content">
<div>
<?lua
if g_is_double_wlan then
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
box.out([[<p>{?1706:459?}</p>]])
else
box.out([[<p>{?1706:617?}</p>]])
end
else
box.out([[<p>{?1706:863?}</p>]])
end
else
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
box.out([[<p>{?1706:810?}</p>]])
else
box.out([[<p>{?1706:664?}</p>]])
end
else
box.out([[<p>{?1706:98?}</p>]])
end
end
?>
</div>
<div>
<hr >
<h4>{?1706:486?}</h4>
<?lua
if g_is_double_wlan then
data_noir = [[wlan/wlan_settings_double.lua]]
else
data_noir = [[wlan/wlan_settings_single.lua]]
end
?>
<?include data_noir?>
</div>
<div id="uiKnownDevices">
<hr >
<h4>{?1706:557?}</h4>
<p>{?1706:555?}</p>
<?lua write_known_wlandevices() ?>
<div class="rightBtn formular" style="<?lua write_expert_features() ?>">
<div id="uiAccessControl">
<span>
<button type="submit" title="{?txtRefresh?}" id="btnRefresh" name="btn_refresh">{?txtRefresh?}</button>
</span>
</div>
</div>
<div class="clear_float"></div>
</div>
<div id="uiViewQRCode">
<hr>
<h4>{?1706:748?}</h4>
<div class="formular">
<span>
<?lua box.out(general.sprintf([[{?1706:736?}]], [[<a href="https://play.google.com/store/apps/details?id=de.avm.android.wlanapp" target="_blank">]],[[</a>]])) ?>
</span>
<br>
<span class="provnote">
<p class="txt_center">
<?lua
if show_both_qrcode() then
box.out([[{?1706:575?}]])
end
?>
</p>
<span id="qrcode" class="provnote"></span>
</span>
<?lua
if show_both_qrcode() then
box.out([[
<span class="provnote">
<p class="txt_center">{?1706:600?}</p>
<span id="qrcodeScnd" class="provnote"></span>
</span>
]])
end
?>
</div>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="RedirAddMac" id="uiRedirAddMac" value="1" disabled>
<?lua net_devices.write_printpreview_btn() ?>
<button type="submit" id="uiApply" name="apply" >{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
