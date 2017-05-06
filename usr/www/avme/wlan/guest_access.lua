<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_wlan_gast.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("general")
require("pushservice")
require("menu")
if not menu.check_page("wlan", [[/wlan/guest_access.lua]]) then
require("http")
require("href")
http.redirect(href.get([[/wlan/wlan_settings.lua]]))
box.end_page()
end
require("filter")
g_no_auto_init_net_devices = true
require("net_devices")
g_is_master = (box.query('box:settings/guest_master') == "1")
g_hide_rep_auto_update = g_is_master or not config.WLAN.has_repeater_guest_ap
g_val = {
prog = [[
if __checked(uiViewActivateGuestAccess/activate_guest_access) then
not_empty(uiViewGuestSsid/guest_ssid, ssid_error_txt)
length(uiViewGuestSsid/guest_ssid, 0, 32, ssid_error_txt)
char_range(uiViewGuestSsid/guest_ssid, 32, 126, ssid_error_txt)
no_lead_char(uiViewGuestSsid/guest_ssid,32,ssid_error_txt)
no_end_char(uiViewGuestSsid/guest_ssid,32,ssid_error_txt)
if __value_not_equal(uiSecMode/sec_mode , 5) then
not_empty(uiViewWpaKey/wpa_key, wpa_key_error_txt)
length(uiViewWpaKey/wpa_key, 8, 63, wpa_key_error_txt)
char_range(uiViewWpaKey/wpa_key, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewWpaKey/wpa_key,32,wpa_key_error_txt)
no_end_char(uiViewWpaKey/wpa_key,32,wpa_key_error_txt)
end
end
]]
}
val.msg.ssid_error_txt = {
[val.ret.empty] = [[{?2031:50?}]],
[val.ret.toolong] = [[{?2031:186?}]],
[val.ret.outofrange] = [[{?2031:8376?}]],
[val.ret.leadchar] = [[{?2031:627?}]],
[val.ret.endchar] = [[{?2031:100?}]]
}
val.msg.wpa_key_error_txt = {
[val.ret.empty] = [[{?2031:718?}]],
[val.ret.toolong] = [[{?2031:778?}]],
[val.ret.tooshort] = [[{?2031:597?}]],
[val.ret.outofrange] = [[{?2031:782?}]],
[val.ret.leadchar] = [[{?2031:480?}]],
[val.ret.endchar] = [[{?2031:587?}]]
}
function add_guest_group_profile(saveset)
local guest_profile_uid = filter.fixed_profile_uid('guest')
local guest_profile = filter.get_profile(guest_profile_uid)
local ruleset_id = filter.get_ruleset_id(guest_profile)
local ruleset_node
if ruleset_id then
ruleset_node = filter.get_ruleset_node(ruleset_id)
else
ruleset_id, ruleset_node = filter.create_ruleset_id_node()
cmtable.add_var(saveset, "internet_ruleset:settings/" .. ruleset_node .. "/id", tostring(ruleset_id))
cmtable.add_var(saveset,
string.format("filter_profile:settings/profile[%s]/internet_ruleset_id", guest_profile_uid),
tostring(ruleset_id)
)
end
local filter_list = general.listquery("internet_ruleset:settings/"..ruleset_node.."/filter_list/entry/list(name)")
if not array.any(filter_list, func.eq("8", "name")) then
local new_id = box.query("internet_ruleset:settings/"..ruleset_node.."/filter_list/entry/newid")
cmtable.add_var(saveset, "internet_ruleset:settings/"..ruleset_node.."/filter_list/"..new_id.."/name", "8")
end
end
function delete_guest_group_profile(saveset)
local guest_profile_uid = filter.fixed_profile_uid('guest')
local guest_profile = filter.get_profile(guest_profile_uid)
local ruleset_id = filter.get_ruleset_id(guest_profile)
local ruleset_node
if ruleset_id then
local cnt = 0
ruleset_node = filter.get_ruleset_node(ruleset_id)
if ruleset_node then
local filter_list = general.listquery("internet_ruleset:settings/"..ruleset_node.."/filter_list/entry/list(name)")
cnt = #filter_list
local i, item = array.find(filter_list, func.eq("8", "name"))
if i and item then
cmtable.add_var(saveset,
"internet_ruleset:command/"..ruleset_node.."/filter_list/"..item._node,
"delete"
)
cnt = cnt - 1
end
end
if cnt < 1 then
cmtable.add_var(saveset,
string.format("filter_profile:settings/profile[%s]/internet_ruleset_id", guest_profile_uid),
"0"
)
end
end
end
function find_guest_group_profile()
filter.refresh_data()
local guest_profile = filter.get_profile(filter.fixed_profile_uid('guest'))
local ruleset_id = filter.get_ruleset_id(guest_profile)
local ruleset_node
if ruleset_id then
ruleset_node = filter.get_ruleset_node(ruleset_id)
end
local result = false
if ruleset_node then
local filter_list = general.listquery("internet_ruleset:settings/"..ruleset_node.."/filter_list/entry/list(name)")
result = array.any(filter_list, func.eq("8", "name"))
end
return result and "1" or "0"
end
if box.post.start_wps then
local ctlmgr_save = {}
cmtable.add_var(ctlmgr_save, "wlan:settings/wps_mode", "2002")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
box.out(general.create_error_div(err,msg))
use_old = true
else
http.redirect(href.get("/wlan/wps_test.lua","wpsmode=pbc&back_to_page=/wlan/guest_access.lua"))
end
elseif box.post.btn_cancel then
elseif next(box.post) and (not g_hide_rep_auto_update or box.query("box:settings/opmode") ~= "opmode_eth_ipclient") then
if box.post.validate == "apply" then
local valresult, answer = val.ajax_validate(g_val)
box.out(js.table(answer))
box.end_page()
end
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
if not g_hide_rep_auto_update then
cmtable.save_checkbox(ctlmgr_save, "wlan:settings/guest_ap_auto_update" , "autoupdate")
end
cmtable.save_checkbox(ctlmgr_save, "wlan:settings/guest_ap_enabled" , "activate_guest_access")
if box.post.activate_guest_access then
cmtable.save_checkbox(ctlmgr_save, "wlan:settings/guest_timeout_active" , "down_time_activ")
if box.post.down_time_activ then
cmtable.save_checkbox(ctlmgr_save, "wlan:settings/guest_no_forced_off" , "disconnect_guest_access")
if box.post.down_time_value then
cmtable.add_var(ctlmgr_save, "wlan:settings/guest_timeout" , box.post.down_time_value)
end
end
if box.post.guest_ssid and box.post.guest_ssid ~= "" then
cmtable.add_var(ctlmgr_save, "wlan:settings/guest_ssid" , box.post.guest_ssid)
end
if box.post.sec_mode and box.post.sec_mode ~= "5" then
if box.post.wpa_key and box.post.wpa_key ~= "" then
cmtable.add_var(ctlmgr_save, "wlan:settings/guest_pskvalue" , box.post.wpa_key)
end
cmtable.add_var(ctlmgr_save, "wlan:settings/guest_encryption" , box.post.sec_mode)
else
cmtable.add_var(ctlmgr_save, "wlan:settings/guest_encryption" , "0")
end
if (g_is_master) then
if (box.post.group_access) then
add_guest_group_profile(ctlmgr_save)
else
delete_guest_group_profile(ctlmgr_save)
end
cmtable.save_checkbox(ctlmgr_save, "emailnotify:settings/wlangueststatus_enabled" , "push_service")
if (box.post.push_service and pushservice.wlan_guest.wlangueststatus_To=="") then
cmtable.add_var(ctlmgr_save, "emailnotify:settings/wlangueststatus_To", pushservice.default_mailto())
end
if (box.post.user_isolation) then
cmtable.add_var(ctlmgr_save, "wlan:settings/guest_user_isolation" , "0")
else
cmtable.add_var(ctlmgr_save, "wlan:settings/guest_user_isolation" , "1")
end
end
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
box.out(general.create_error_div(err,msg))
end
else
use_old = true
end
end
function retrieve_userdate(value)
if value then
return "1"
else
return "0"
end
end
g_ctlmgr = {}
g_ctlmgr.wlan_ap_enabled = box.query("wlan:settings/ap_enabled")
g_ctlmgr.wlan_bg_mode = box.query("wlan:settings/bg_mode")
if config.WLAN.has_11ac then
g_ctlmgr.wlan_bg_mode_scnd = box.query("wlan:settings/bg_mode_scnd")
end
g_ctlmgr.wlan_channel = box.query("wlan:settings/channel")
g_ctlmgr.wlan_ap_enabled_scnd = box.query("wlan:settings/ap_enabled_scnd")
g_ctlmgr.wlan_channel_scnd = box.query("wlan:settings/channel_scnd")
g_ctlmgr.wlanguest_time_remain = box.query("wlan:settings/guest_time_remain")
if use_old then
g_ctlmgr.guest_ap_enabled = retrieve_userdate(box.post.activate_guest_access)
g_ctlmgr.guest_timeout_active = retrieve_userdate(box.post.down_time_activ)
g_ctlmgr.guest_timeout = tostring(box.post.down_time_value)
g_ctlmgr.guest_no_forced_off = retrieve_userdate(box.post.disconnect_guest_access)
g_ctlmgr.guest_ssid = tostring(box.post.guest_ssid)
if box.post.sec_mode=="5" then
g_ctlmgr.guest_encryption = "0"
else
g_ctlmgr.guest_encryption = tostring(box.post.sec_mode)
end
g_ctlmgr.guest_pskvalue = tostring(box.post.wpa_key)
else
g_ctlmgr.guest_ap_enabled = box.query("wlan:settings/guest_ap_enabled")
g_ctlmgr.guest_timeout_active = box.query("wlan:settings/guest_timeout_active")
g_ctlmgr.guest_timeout = box.query("wlan:settings/guest_timeout")
g_ctlmgr.guest_no_forced_off = box.query("wlan:settings/guest_no_forced_off")
g_ctlmgr.guest_ssid = box.query("wlan:settings/guest_ssid")
if g_ctlmgr.guest_ssid == "" then
g_ctlmgr.guest_ssid = [[{?2031:709?}]]
end
g_ctlmgr.guest_encryption = box.query("wlan:settings/guest_encryption")
g_ctlmgr.guest_pskvalue = box.query("wlan:settings/guest_pskvalue")
end
g_ctlmgr.pskvalue = box.query("wlan:settings/pskvalue")
g_ctlmgr.master_ssid =box.query("wlan:settings/ssid")
g_ctlmgr.master_ssid_scnd=box.query("wlan:settings/ssid_scnd")
g_ctlmgr.encryption = box.query("wlan:settings/encryption")
if not config.WLAN.is_double_wlan then
g_ctlmgr.master_ssid_scnd=g_ctlmgr.master_ssid
end
g_ctlmgr.guest_push_service = box.query("emailnotify:settings/wlangueststatus_enabled")
g_ctlmgr.guest_group_access = find_guest_group_profile()
g_ctlmgr.guest_user_isolation = "1"
if (box.query("wlan:settings/guest_user_isolation")=="1") then
g_ctlmgr.guest_user_isolation = "0"
end
function write_wlan_channel(wlan_channel)
if wlan_channel and wlan_channel ~= "0" then
box.out([[{?2031:286?} ]]..wlan_channel)
else
box.out([[{?2031:625?}]])
end
end
function get_time_str()
local time=tonumber(g_ctlmgr.wlanguest_time_remain)
local str = ""
local rest_time_min_sing = [[{?2031:769?}]]
local rest_time_hour_sing = [[{?2031:723?}]]
local rest_time_min_plu = [[{?2031:78?}]]
local rest_time_hour_plu = [[{?2031:23?}]]
if time and time > 0 then
local calc_time = time/60
if time < 91 or calc_time < 1 then
str = ' ('..time..' '
if time == 1 then
str = str..rest_time_min_sing
elseif time > 1 then
str = str..rest_time_min_plu
end
str = str..')'
else
str = ' (ca '..string.format("%.0f", calc_time)..' '
if calc_time == 1 then
str = str..rest_time_hour_sing
elseif calc_time > 1 then
str = str..rest_time_hour_plu
end
str = str..')'
end
end
return str
end
function write_checked(condition)
if (condition and condition=="1") then
box.out([[ checked ]])
end
end
function write_active()
if box.query("wlan:settings/wlan_config_status") =="fail" then
box.out([[ disabled ]])
return
end
write_checked(g_ctlmgr.guest_ap_enabled)
end
function write_wlan_failed()
if box.query("wlan:settings/wlan_config_status") =="fail" then
box.out([[ class="disableNode" ]])
end
end
function is_pushservice_configured()
if not pushservice.account_configured() then
return false
end
return true
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<style type="text/css">
.va_top {
vertical-align: top;
}
#qrcode {
margin-top:10px;
}
</style>
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div id="disable_all" >
<div style="<?lua if not g_hide_rep_auto_update then box.out([[display:none;]]) end ?>">
<p>
{?2031:4156?}
<a target="_blank" href="<?lua require('helpurl') box.out(helpurl.get([[hilfe_wlan_gast_hinweis]]))?>">{?2031:417?}</a>
</p>
</div>
<div style="<?lua if g_hide_rep_auto_update then box.out([[display:none;]]) end ?>">
<p>
<?lua
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
box.out([[{?2031:454?}]])
else
box.out([[{?2031:871?}]])
end
else
box.out([[{?2031:258?}]])
end
?>
</p>
<div class="formular">
<input type="checkbox" id="uiAutoupdate" name="autoupdate" onclick="onAutoupdate()" <?lua write_checked(box.query("wlan:settings/guest_ap_auto_update")) ?>><label for="uiAutoupdate">{?2031:150?}</label>
<div class="form_input_explain">
<div>
<h4>{?txtHinweis?}</h4>
{?2031:244?}
</div>
<div>
<?lua
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
box.out([[{?2031:870?}]])
else
box.out([[{?2031:72?}]])
end
else
box.out([[{?2031:384?}]])
end
?>
</div>
</div>
</div>
</div>
<div id="uiGuestManu">
<hr>
<h4>{?2031:214?}</h4>
<div >
<div <?lua write_wlan_failed() ?>>
<input type="checkbox" id="uiViewActivateGuestAccess" name="activate_guest_access" onclick="onGuestWlanActiv()" <?lua write_active() ?>>
<label for="uiViewActivateGuestAccess">{?2031:872?}<!-- <?lua box.out(get_time_str()) ?> --></label>
</div>
<div id="uiViewGuestInstall" class="formular">
<div>
<label for="uiViewGuestSsid">{?2031:93?}</label>
<input type="text" size="33" maxlength="32" id="uiViewGuestSsid" name="guest_ssid" onpaste="valuesChanged()" oninput="valuesChanged()" value="<?lua if g_ctlmgr.guest_ssid then box.html(g_ctlmgr.guest_ssid) else box.html([[{?2031:232?}]]) end ?>" >
</div>
<div id="uiViewGuestSecurity">
<div>
<label for="uiSecMode">{?2031:73?}</label>
<select id="uiSecMode" name="sec_mode" onchange="onWlanSecurity();valuesChanged();" size="1">
<?lua
local enc = {1,"WPA (TKIP)", "WPA2 (CCMP)", "WPA + WPA2", "{?2031:665?}"}
local key, val
for i=2, 5, 1 do
box.out('<option value="'..i..'" ')
if tonumber(g_ctlmgr.guest_encryption) and (tonumber(g_ctlmgr.guest_encryption) == tonumber(i) or (g_ctlmgr.guest_encryption=="0" and i==5)) then
box.out('selected="selected"')
selected = true
end
if selected==nil and i==5 then
box.out('selected="selected"')
end
box.out('>'..enc[i]..'</option>\n')
end
?>
</select>
</div>
<div id="uiViewWpaDialogBox" <?lua if tonumber(g_ctlmgr.guest_encryption) and tonumber(g_ctlmgr.guest_encryption) < 2 then box.out('style="display:none"') end ?>>
<p>{?2031:117?}</p>
<label for="uiViewWpaKey">{?2031:933?}</label>
<input type="text" maxlength="63" id="uiViewWpaKey" name="wpa_key" onpaste="valuesChanged()" oninput="valuesChanged()" value="<?lua if g_ctlmgr.guest_pskvalue then box.html(g_ctlmgr.guest_pskvalue) else box.out('') end ?>" >
</div>
<div id="uiViewNoneDialogBox" <?lua if tonumber(g_ctlmgr.guest_encryption) and tonumber(g_ctlmgr.guest_encryption) ~= 0 then box.out('style="display:none"') end ?>>
<h4>{?txtHinweis?}</h4>
<p>{?2031:459?}</p>
</div>
</div>
<div style="<?lua if not g_is_master then box.out('display:none') end ?>">
<div style="<?lua if is_pushservice_configured() then box.out('display:none;') end ?>">
<div class="disableNode">
<input type="checkbox" id="uiDisableMe" disabled>
<label >{?2031:493?}</label>
</div>
<p class="form_checkbox_explain"><?lua box.out(general.sprintf([[{?2031:904?}]],[[<a href="]]..href.get([[/system/push_list.lua]])..[[">]],[[</a>]])) ?> </p>
</div>
<div style="<?lua if not is_pushservice_configured() then box.out('display:none;') end ?>">
<input type="checkbox" id="uiPushService" name="push_service" onclick="" <?lua write_checked(g_ctlmgr.guest_push_service) ?>>
<label for="uiPushService">{?2031:98?}</label>
</div>
<div>
<input type="checkbox" id="uiGroupAccess" name="group_access" onclick="" <?lua write_checked(g_ctlmgr.guest_group_access) ?>>
<label for="uiGroupAccess">{?2031:1282?}</label>
</div>
<div>
<input type="checkbox" id="uiUserIsolation" name="user_isolation" onclick="" <?lua write_checked(g_ctlmgr.guest_user_isolation) ?>>
<label for="uiUserIsolation">{?2031:237?}</label>
</div>
</div>
<div>
<input type="checkbox" id="uiViewDownTimeActiv" name="down_time_activ" onclick="onDownTimerActiv()" <?lua write_checked(g_ctlmgr.guest_timeout_active) ?>>
<label id="uiViewDownTimeActivLabel" for="uiViewDownTimeActiv">{?2031:201?}</label>
<span id="uiViewDownTimeBox">
<select id="uiViewDownTime" name="down_time_value" size="1">
<?lua
local minu = [[{?2031:744?}]]
local stu = [[{?2031:613?}]]
local times = {{txt="15 "..minu,val=15},
{txt="30 "..minu,val=30},
{txt="45 "..minu,val=45},
{txt="60 "..minu,val=60},
{txt="90 "..minu,val=90},
{txt=" 2 "..stu,val=120},
{txt=" 3 "..stu,val=180},
{txt=" 4 "..stu,val=240},
{txt=" 5 "..stu,val=300},
{txt=" 6 "..stu,val=360},
{txt=" 8 "..stu,val=480},
{txt="10 "..stu,val=600},
{txt="12 "..stu,val=720},
{txt="15 "..stu,val=900},
{txt="18 "..stu,val=1080},
{txt="21 "..stu,val=1260}}
local key, val
for i,v in ipairs(times) do
box.out('<option value="'..v.val..'" ')
if g_ctlmgr.guest_timeout and tonumber(g_ctlmgr.guest_timeout) == tonumber(v.val) then box.out('selected="selected"') end
box.out('>'..v.txt..'</option>\n')
end
?>
</select>
</span>
<div id="uiViewDisconnectGuestAccessBox" class="formular">
<input type="checkbox" id="uiViewDisconnectGuestAccess" name="disconnect_guest_access" onclick="" <?lua if g_ctlmgr.guest_no_forced_off and g_ctlmgr.guest_no_forced_off == "1" then box.out('checked') end ?>>
<label for="uiViewDisconnectGuestAccess">{?2031:411?}</label>
</div>
</div>
</div>
</div>
<div id="uiViewQRCode">
<hr>
<h4>{?2031:626?}</h4>
<div class="formular">
<span>
<?lua box.out(general.sprintf([[{?2031:52?}]], [[<a href="https://play.google.com/store/apps/details?id=de.avm.android.wlanapp" target="_blank">]],[[</a>]])) ?>
</span>
<br>
<div id="qrcode"></div>
</div>
</div>
<div id="uiViewWps">
<hr>
<h4>{?2031:418?}</h4>
<div class="rightBtn formular">
<span>{?2031:382?}</span>
<br>
<br>
<div>
<button type="submit" id="uiStartWPS" name="start_wps" disabled = "disabled">{?2031:268?}</button>
</div>
</div>
</div>
</div>
</div>
<div id="btn_form_foot">
<?lua net_devices.write_printpreview_btn(g_ctlmgr.guest_ap_enabled == "1") ?>
<button type="submit" name="apply" >{?txtApply?}</button>
<button type="submit" name="btn_cancel" id="btnChancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/qrcode.js"></script>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
<?lua
net_devices.write_showPrintView_func("guest")
?>
function onWlanSecurity()
{
var cur_sec=jxl.getValue("uiSecMode");
jxl.display("uiViewWpaDialogBox", cur_sec!=5);
jxl.display("uiViewNoneDialogBox", cur_sec==5);
}
function onDownTimerActiv()
{
jxl.disableNode("uiViewDownTimeBox", !jxl.getChecked("uiViewActivateGuestAccess") || !jxl.getChecked("uiViewDownTimeActiv"));
jxl.disableNode("uiViewDisconnectGuestAccessBox", !jxl.getChecked("uiViewActivateGuestAccess") || !jxl.getChecked("uiViewDownTimeActiv"));
}
function onAutoupdate()
{
var hide = !jxl.getChecked("uiAutoupdate");
jxl.display("uiGuestManu", hide);
}
function onGuestWlanActiv()
{
var disable = !jxl.getChecked("uiViewActivateGuestAccess");
jxl.disableNode("uiViewDownTimeActiv", disable);
jxl.disableNode("uiViewDownTimeActivLabel", disable);
jxl.disableNode("uiViewGuestInstall", disable);
jxl.disableNode("uiViewGuestSecurity", disable);
jxl.disableNode("uiViewQRCode", disable);
<?lua
if g_ctlmgr.guest_encryption == "0" or g_ctlmgr.guest_encryption == "2" then
box.out([[jxl.disableNode("uiViewWps", true);]])
else
box.out([[jxl.disableNode("uiViewWps", disable, true);]])
if(g_ctlmgr.guest_ap_enabled == "1") then
box.out([[jxl.setDisabled("uiStartWPS", disable);]])
end
end
?>
jxl.disable("uiDisableMe");
onDownTimerActiv();
}
function onWlanGuestSubmit()
{
check_timer_activ();
}
function check_timer_activ()
{
if (jxl.getChecked("uiViewActivateGuestAccess") && jxl.getChecked("uiViewDownTimeActiv"))
{
var time = Number(jxl.getValue("uiViewDownTime"));
var time_str = jxl.getValue("uiViewDownTime");
if (time > 90)
time_str = (time/60).toString() + " {?2031:83?}"
else
time_str = time.toString() + " {?2031:901?}"
alert('{?2031:873?} '+time_str+' {?2031:935?}');
}
}
function valuesChanged()
{
jxl.disable("uiViewPrintButton");
}
function init()
{
createPasswordChecker( "uiViewWpaKey", 8 );
var disable_all = <?lua box.out(tostring((box.query("box:settings/opmode") == "opmode_eth_ipclient") and g_hide_rep_auto_update)) ?>;
if (disable_all)
jxl.disableNode("disable_all", true);
onGuestWlanActiv();
<?lua
if not g_hide_rep_auto_update then
box.out([[onAutoupdate();]])
end
?>
if (!isCanvasSupported()){
jxl.display("uiViewQRCode", false);
return;
}
updateQRCode("qrcode", "<?lua box.js(net_devices.get_wlan_qr_string(g_ctlmgr.guest_ssid, g_ctlmgr.guest_encryption, g_ctlmgr.guest_pskvalue)) ?>");
}
ready.onReady(ajaxValidation({
okCallback: onWlanGuestSubmit
}));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
