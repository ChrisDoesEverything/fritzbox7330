<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_wlan_wds.html"
dofile("../templates/global_lua.lua")
require("general")
require("http")
require("cmtable")
require("val")
require("wlanscan")
require("net_devices")
require("menu")
if not menu.check_page("wlan", [[/wlan/wds2.lua]]) then
require("http")
require("href")
http.redirect(href.get([[/wlan/wlan_settings.lua]]))
box.end_page()
end
g_err = {}
g_val = {
prog = [[
if __radio_check(uiViewMode1/Mode, repeater) then
not_empty(uiViewpskvalue/pskvalue, wpa_key_error_txt)
length(uiViewpskvalue/pskvalue, 8, 63, wpa_key_error_txt)
char_range(uiViewpskvalue/pskvalue, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewpskvalue/pskvalue, 32, wpa_key_error_txt)
no_end_char(uiViewpskvalue/pskvalue, 32, wpa_key_error_txt)
end
]]
}
val.msg.wpa_key_error_txt = {
[val.ret.empty] = [[{?1807:925?}]],
[val.ret.toolong] = [[{?1807:78?}]],
[val.ret.tooshort] = [[{?1807:301?}]],
[val.ret.outofrange] = [[{?1807:859?}]],
[val.ret.leadchar] = [[{?1807:879?}]],
[val.ret.endchar] = [[{?1807:440?}]]
}
local function get_ap_scanvalue(value)
local t = (value or ""):split("§")
return {
mac = t[1], channel = t[2], encryption = t[3],
ssid = table.concat(array.slice(t, 4), "§")
}
end
local function build_wds2_final_url(values)
local url = "/wds2_final.lua"
local encstr = {wpa2 = [[WPA2]], wpamixed = [[WPA+WPA2]]}
local params = {
http.url_param("ssid", values.ssid or ""),
http.url_param("encryption", encstr[values.encryption] or ""),
http.url_param("key", values.pskvalue or "")
}
return url .. "?" .. table.concat(params, "&")
end
local function build_change_isp_url()
local url = "/internet/isp_change.lua"
local params = {
http.url_param("pagetype", "all"),
http.url_param("pagemaster", box.glob.script)
}
return url .. "?" .. table.concat(params, "&")
end
local function save_basis(saveset)
local redirect_url
cmtable.add_var(saveset, "wlan:settings/WDS_enabled", "0")
cmtable.add_var(saveset, "wlan:settings/WDS_hop", "0")
cmtable.add_var(saveset, "wlan:settings/WDS_encryption", "3")
local old_mode = "basis"
if box.query("wlan:settings/WDS_enabled") == "1" and box.query("wlan:settings/WDS_hop") == "1" then
old_mode = "repeater"
end
if old_mode == "repeater" and general.is_ip_client() then
cmtable.add_var(saveset, "providerlist:settings/activeprovider", "other")
cmtable.add_var(saveset, "box:settings/opmode", "opmode_modem")
redirect_url = build_change_isp_url()
end
return redirect_url
end
local function save_repeater(wlan_saveset, ipclient_saveset)
local redirect_url
cmtable.add_var(wlan_saveset, "wlan:settings/WDS_enabled", "1")
cmtable.add_var(wlan_saveset, "wlan:settings/WDS_hop", "1")
cmtable.add_var(wlan_saveset, "wlan:settings/WDS_encryption", "3")
cmtable.add_var(wlan_saveset, "wlan:settings/WDS_key", box.post.pskvalue or "")
if config.WLAN.is_double_wlan then
if box.query("wlan:settings/ap_enabled_scnd") == "1" then
cmtable.add_var(wlan_saveset, "wlan:settings/channel_scnd", "0")
end
end
local values = {}
for i, name in ipairs(general.sorted_by_i(box.post)) do
if name:find("check") == 1 then
values = get_ap_scanvalue(box.post[name])
g_WDS_mac_master = values.mac or "00:00:00:00:00:00"
cmtable.add_var(wlan_saveset, "wlan:settings/WDS_mac_master", g_WDS_mac_master)
break
end
end
if config.WLAN_GUEST == 1 then
cmtable.add_var(wlan_saveset, "wlan:settings/guest_ap_enabled", "0")
cmtable.add_var(wlan_saveset, "wlan:settings/guest_pskvalue", "")
cmtable.add_var(wlan_saveset, "wlan:settings/guest_encryption", "4")
end
if not general.is_ip_client() then
cmtable.add_var(ipclient_saveset, "providerlist:settings/activeprovider", "other")
cmtable.add_var(ipclient_saveset, "box:settings/opmode", "opmode_eth_ipclient")
values.pskvalue = box.post.pskvalue or ""
redirect_url = build_wds2_final_url(values)
end
cmtable.add_var(ipclient_saveset, "interfaces:settings/lan0/dhcpclient", "1")
cmtable.add_var(ipclient_saveset, "box:settings/dhcpclient/use_static_dns", "0")
return redirect_url
end
if box.post then
if box.post.validate == "apply" then
local valresult, answer = val.ajax_validate(g_val)
box.out(js.table(answer))
box.end_page()
end
local val_result = val.validate(g_val)
if val_result == val.ret.ok then
local redirect_url
local wlan_saveset = {}
local ipclient_saveset = {}
if box.post.Mode == "basis" then
redirect_url = save_basis(wlan_saveset)
elseif box.post.Mode == "repeater" then
redirect_url = save_repeater(wlan_saveset, ipclient_saveset)
end
g_err.code, g_err.msg = box.set_config(wlan_saveset)
if g_err.code == 0 then
if next(ipclient_saveset) then
g_err.code, g_err.msg = box.set_config(ipclient_saveset)
end
end
if g_err.code == 0 and redirect_url then
http.redirect(redirect_url)
end
end
elseif box.post.refresh_list then
local saveset = {}
cmtable.add_var(saveset, "wlan:settings/scan_apenv", "2")
g_err.code, g_err.msg = box.set_config(saveset)
http.redirect(href.get(box.glob.script))
end
g_wlanList = wlanscan.get_wlan_scan_list()
g_ap_env_state = box.query("wlan:settings/APEnvStatus")
g_CurrentMode = "basis"
if box.query("wlan:settings/WDS_enabled") == "1" and box.query("wlan:settings/WDS_hop") == "1" then
g_CurrentMode = "repeater"
end
g_WDS_mac_master = box.query("wlan:settings/WDS_mac_master")
g_pskvalue = box.query("wlan:settings/WDS_key")
g_CurrentEncrypt = box.query("wlan:settings/encryption")
g_is_double_wlan = false
g_active = box.query("wlan:settings/ap_enabled") == "1"
g_active_scnd = false
if config.WLAN.is_double_wlan then
g_is_double_wlan = true
g_active_scnd = box.query("wlan:settings/ap_enabled_scnd") == "1"
end
function compareByRssiAndChecked(dev1, dev2)
if (dev1.checked and dev2.checked) then
return false
end
if (dev1.checked) then
return true
end
if (dev2.checked) then
return false
end
local rssi1 = tonumber(dev1.rssi) or 0;
local rssi2 = tonumber(dev2.rssi) or 0;
if (rssi1 < rssi2) then
return false
elseif (rssi1 > rssi2) then
return true
end
return false
end
function get_mode_checked(mode)
if mode==g_CurrentMode then
return [[ checked]]
end
return ""
end
function get_pskvalue()
return g_pskvalue or ""
end
function get_wlan_devices(force)
net_devices.check_and_add(g_wlanList, g_WDS_mac_master)
if (g_wlanList) then
local wds2_aps, nonwds2_aps = array.filter(g_wlanList, net_devices.wds2_capable)
table.sort(wds2_aps, compareByRssiAndChecked)
table.sort(nonwds2_aps, compareByRssiAndChecked)
g_wlanList = array.cat(wds2_aps, nonwds2_aps)
end
local show_checkboxes = true
local show_encryption = true
local show_scan = false
local show_wds2 = true
return wlanscan.create_wlan_scan_table(g_wlanList, force, show_checkboxes, show_encryption, show_scan, show_wds2)
end
function get_num_checked()
return wlanscan.get_num_of_checked(g_wlanList)
end
function write_save_error()
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
g_ajax = false
g_startscan = false
if box.get.useajax then
g_ajax = true
g_startscan = box.get.startscan
end
if box.post.useajax then
g_ajax = true
g_startscan = box.post.startscan
end
if g_ajax then
if g_startscan then
local saveset = {}
cmtable.add_var(saveset, "wlan:settings/scan_apenv", "2")
box.set_config(saveset)
box.out([["StartScan":1,]])
else
box.out([["StartScan":]], tostring(box.query("wlan:settings/APEnvStatus")), [[,]])
end
box.out([["WlanList":]])
box.out(get_wlan_devices())
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
.basis .hideif_basis {
display: none;
}
</style>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="mainform" id="uiMainform" class="<?lua box.html(g_CurrentMode) ?>">
<?lua write_save_error() ?>
<p>
{?1807:839?}
</p>
<p>
{?1807:341?}
</p>
<p>
{?1807:904?}
</p>
<hr>
<h4>{?1807:308?}</h4>
<div class="formular">
<input type="radio" onclick="OnDoWDSMode('basis')" name="Mode" value="basis" id="uiViewMode0" <?lua box.out(get_mode_checked("basis")) ?>>
<label for="uiViewMode0">{?1807:2105?}</label>
<p class="form_input_explain">
{?1807:462?}
</p>
<input type="radio" onclick="OnDoWDSMode('repeater')" name="Mode" value="repeater" id="uiViewMode1" <?lua box.out(get_mode_checked("repeater")) ?>>
<label for="uiViewMode1">{?1807:254?}</label>
<p class="form_input_explain">
{?1807:712?}
</p>
</div>
<div class="hideif_basis">
<div class="blue_separator_back">
<h2>
{?1807:527?}
</h2>
</div>
<p>
{?1807:797?}
</p>
<div id="uiWlanDev">
<h4>
{?1807:59?}
</h4>
<div id="uiWlanListDiv">
<div id="uiWlanCurList">
<?lua box.out(get_wlan_devices()) ?>
</div>
<div class="btn_form">
<button type="submit" id="uiIdRenewList" name="refresh_list" onclick="return OnDoRefresh();">
{?1807:387?}
</button>
</div>
</div>
</div>
<hr>
<h4>
{?1807:377?}
</h4>
<p>
{?1807:148?}
</p>
<div class="formular">
<label for="uiViewpskvalue">
{?1807:800?}
</label>
<input type="text" size="40" maxlength="63" name="pskvalue" id="uiViewpskvalue" onkeyup="OnChangeInput(this.value,'uiDezKeyWpa')" value="<?lua box.html(get_pskvalue()) ?>">
<div class="form_input_note cnt_char">
<span id="uiDezKeyWpa">
<?lua box.out(#get_pskvalue()) ?>
</span>
{?gNumOfChars?}
</div>
</div>
<hr>
<h4>{?1807:53?}</h4>
<div class="formular">
<?lua
if config.WLAN.is_double_wlan then
box.out([[<p>{?1807:117?}</p>
<label for="uiViewMac24">{?1807:13?}</label>
]])
else
box.out([[<p>{?1807:366?}</p>
<label for="uiViewMac24">{?1807:272?}</label>
]])
end
?>
<span id="uiViewMac24"><?lua box.out(box.query("wlan:settings/wlanmac_repeater")) ?></span>
<?lua
if config.WLAN.is_double_wlan then
box.out([[
<br>
<label for="uiViewMac5">{?1807:343?}</label>
<span id="uiViewMac5">]], box.query("wlan:settings/wlanmac_repeater_scnd"), [[</span>]])
end
?>
<div class="formular">
<?lua
if config.WLAN.is_double_wlan then
box.out([[<p>{?1807:939?}</p>]])
else
box.out([[<p>{?1807:725?}</p>]])
end
?>
</div>
</div>
</div>
<hr>
<h4>{?txtHinweis?}</h4>
<p>
{?1807:442?}
</p>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div id="btn_form_foot">
<button type="submit" id="uiApply" name="apply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort = sorter();
var g_num_of_checked = <?lua box.out(get_num_checked()) ?>;
var g_CurrentMode = "<?lua box.out(g_CurrentMode) ?>";
var g_isDoubleWlan = <?lua box.out(tostring(g_is_double_wlan)) ?>;
var g_ap_env_state = "<?lua box.js(box.query('wlan:settings/APEnvStatus')) ?>";
var g_RepeaterValue = "";
var g_QueryVars = {
status: { query: "wlan:settings/APEnvStatus" },
channel: { query: "wlan:settings/channel" },
used_channel: { query: "wlan:settings/used_channel" }
}
var g_AktualTimeout=10000;
var g_cbCount=0;
function cbRefresh(response)
{
if (response && response.status == 200)
{
if (response.responseText != "")
{
var resp=response.responseText.split(',"WlanList":');
var respStartScan = resp[0].replace('"StartScan":',"");
var respWlanList = resp[1];
if (resp)
{
jxl.setHtml("uiWlanCurList", respWlanList);
if (jxl.get("uiScanResult"))
{
sort.init("uiScanResult");
if (jxl.get("uiListOfAps"))
{
sort.addTbl(uiListOfAps);
}
sort.sort_table(0);
}
if (respStartScan!="1")
{
zebra();
jxl.enable("uiIdRenewList");
return;
}
}
}
window.setTimeout(doRequestRefreshData, 2000);
}
}
function doRequestRefreshData(start)
{
var my_url = "<?lua box.js(box.glob.script) ?>?sid=<?lua box.js(box.glob.sid) ?>&useajax=1";
if (start)
{
my_url+="&startscan=1";
}
ajaxGet(my_url, cbRefresh);
}
function cbState()
{
switch (g_QueryVars.status.value)
{
case "0":
{
doRequestRefreshData();
return true;
}
default:
{
g_cbCount++;
if (g_cbCount < 30)
{
return false;
}
jxl.setHtml("uiWlanCurList", "<?lua box.out(get_wlan_devices(true))?>");
if (jxl.get("uiScanResult"))
{
sort.init("uiScanResult");
if (jxl.get("uiListOfAps"))
{
sort.addTbl(uiListOfAps);
}
sort.sort_table(0);
}
jxl.enable("uiIdRenewList");
return true;
}
}
return false;
}
function init()
{
jxl.removeClass("uiListOfAps", "repeater");
jxl.addClass("uiListOfAps", "basis");
if (jxl.getChecked("uiViewMode0")) {
OnDoWDSMode("basis");
}
else if (jxl.getChecked("uiViewMode1")) {
OnDoWDSMode("repeater");
}
if (g_ap_env_state != "0")
{
jxl.disable("uiIdRenewList");
g_cbCount = 0;
ajaxWait(g_QueryVars, "<?lua box.js(box.glob.sid) ?>", g_AktualTimeout, cbState);
}
}
function check_selected(num_of_checked)
{
if (g_CurrentMode == "basis")
{
return true;
}
if (g_CurrentMode == "repeater")
{
var msg;
if (num_of_checked == 0)
{
msg = "{?1807:478?}";
}
if (num_of_checked > 1)
{
msg = "{?1807:891?}";
}
if (msg)
{
alert(msg);
return false;
}
}
return true;
}
function uiDoOnMainFormSubmit()
{
return check_selected(CountChecked());
}
function OnDoRefresh()
{
doRequestRefreshData(true);
return false;
}
function OnDoWDSMode(mode)
{
var oldclass = g_CurrentMode;
g_CurrentMode = mode;
if (oldclass != g_CurrentMode)
{
jxl.removeClass("uiMainform", oldclass);
jxl.addClass("uiMainform", g_CurrentMode);
}
}
function OnChangeInput(value, id)
{
jxl.setText(id, value.length);
}
function CountChecked()
{
var count = 0;
jxl.walkDom("uiListOfAps", "tr", function(tr) {
if (jxl.hasClass(tr, "highlight")) {
count++;
}
});
return count;
}
function getApScanvalue(value)
{
var t = (value || "").split("§");
return {
mac: t[0], channel: t[1], encryption: t[2],
ssid: t.slice(3).join("§")
};
}
function checkEncryption(elem)
{
var values = jxl.getValue(elem);
values = getApScanvalue(values);
var enc = values.encryption || "";
if (enc != "wpamixed" && enc != "wpa2")
{
alert(
"{?1807:596?}"
);
}
}
function UncheckAll(elem)
{
jxl.walkDom("uiListOfAps", "tr", function(tr)
{
jxl.walkDom(tr, "input", function(checkbox)
{
if (checkbox.type == 'checkbox' && elem != checkbox)
{
jxl.removeClass(tr, "highlight");
jxl.setChecked(checkbox, false);
}
});
});
}
function OnChangeActive(elem, n)
{
if (!elem.checked)
{
return false;
}
checkEncryption(elem);
UncheckAll(elem);
jxl.addClass("uiViewRow" + n, "highlight");
g_RepeaterValue = elem.value;
return true;
}
function initTableSorter() {
if (jxl.get("uiScanResult"))
{
sort.init("uiScanResult");
if (jxl.get("uiListOfAps"))
{
sort.addTbl(uiListOfAps);
}
sort.sort_table(0);
}
}
ready.onReady(initTableSorter);
ready.onReady(init);
ready.onReady(ajaxValidation({
okCallback: uiDoOnMainFormSubmit
}));
</script>
<?include "templates/html_end.html" ?>
