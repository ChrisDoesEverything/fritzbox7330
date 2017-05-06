<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_netzwerk_ip.html"
dofile("../templates/global_lua.lua")
require("general")
require("http")
require("cmtable")
require("val")
require("html")
g_var = {}
function show_smarthome_broadcast()
require("libaha")
if aha.GetSmartHomeStateInfos then
local state_info = aha.GetSmartHomeStateInfos()
if state_info.Running==1 then
return true
end
end
return false
end
function is_lan4_vpn()
local is_vpn = false
for i = 0, 7 , 1 do
ipsecbr_interfaces = box.query("vpn:settings/connection"..i .."/ipsecbr_interfaces")
if string.find(ipsecbr_interfaces,"eth3") then
is_vpn = true
end
end
return is_vpn
end
function show_buttons()
local lRet = false
if (config.ETH_GBIT or general.is_expert()) then
lRet = lRet or true
if (config.IPV6) then
lRet = lRet or true
end
end
return lRet
end
function get_page_var()
if show_smarthome_broadcast() then
local state_info = aha.GetSmartHomeStateInfos() or {ExtInetIfEnabled=0}
g_var.use_broadcast = state_info.ExtInetIfEnabled == 1
end
g_var.upnp_activ = box.query("box:settings/upnp/activated") == "1"
g_var.tr064_enabled = box.query("tr064:settings/enabled") == "1"
g_var.time_enabled = box.query("time:settings/chrony_enabled") == "1"
g_var.time_server = box.query("time:settings/ntp_server")
g_var.opmode = box.query("box:settings/opmode")
g_var.dnsv6server = box.query("ipv6:settings/radv_advdns") == "1"
g_var.otherprefixallowed = box.query("ipv6:settings/otherprefixesallowed") == "1"
g_var.guest_enabled = box.query("box:settings/ethernet_guest_enabled")=="1"
g_var.ipv6_pref = box.query("ipv6:settings/dhcpv6d_preference")
g_var.lan4_bridged = false
require("menu")
if menu.exists_page("/internet/lanbridges.lua") then
local tmp = general.listquery("nqos:settings/classifier/list(enabled,name)")
for i, item in ipairs(tmp) do
if item.name == "ethport_4" and item.enabled == "1" then
g_var.lan4_bridged = true
end
end
end
end
function no_gbit(idx)
local speed = tonumber(box.query("eth" .. (idx-1) .. ":status/maxspeed")) or 0
return speed < 1000
end
function is_IPv6_enabled()
return box.query("ipv6:settings/enabled") == "1"
end
function write_head_trs()
local zebrahack = html.tr{style="display:none;",
html.th{colspan="3"}
}
html.tr{
html.th{[[{?859:769?}]]},
html.th{[[{?859:697?}]]},
html.th{[[{?859:34?}]]}
}.write()
zebrahack.write()
local txt_1gbit = [[{?859:911?}]]
local txt_100mbit = [[{?859:708?}]]
html.tr{
html.td{},
html.td{txt_1gbit},
html.td{txt_100mbit}
}.write()
end
local function lan_name(idx)
local txt = [[{?859:291?}]]
return txt .. [[ ]] .. idx
end
local function get_radio(idx, val)
local str_i = tostring(idx - 1)
local eth_i = "eth" .. str_i
local td = html.td{class="radio_td"}
local radio = html.input{type="radio", name=eth_i, value=val}
if box.query(eth_i .. ":settings/mode") == val then
radio.checked = ""
end
radio.id = "uiOn_" .. str_i .. "_" .. val
td.add(radio)
return td
end
local function deactivatable(idx)
return idx > 1
end
local hyphen = [[ — ]]
function write_radios()
local empty_td = html.td{class="empty_td", hyphen}
local tr, radio_td
for i = 1, config.ETH_COUNT do
tr = html.tr{}
tr.add(html.th{lan_name(i)})
if no_gbit(i) then
tr.add(empty_td)
else
tr.add(get_radio(i, "2"))
end
tr.add(get_radio(i, "1"))
tr.write()
end
end
function write_list()
--dns_excepted_domains
local list = general.listquery("dns_excepted_domains:settings/domain/list(name)")
for i, domain in ipairs(list) do
if i > 1 then
box.out("\n")
end
box.html(domain.name)
end
end
local function max_val(idx)
return no_gbit(idx) and 2 or 3
end
g_val = {
prog = [[
not_empty(uiViewIpv6Pref/ipv6_pref, ipv6_pref)
char_range_regex(uiViewIpv6Pref/ipv6_pref, decimals, ipv6_pref)
num_range(uiViewIpv6Pref/ipv6_pref,0,255,ipv6_pref)
]]
}
if not general.is_ip_client() then
g_val.prog=g_val.prog..[[
not_empty(uiViewTimeServerList/time_server, netset)
]]
end
val.msg.netset = {
[val.ret.empty] = [[{?859:365?}]]
}
local pref_msg=[[{?859:684?}]]
val.msg.ipv6_pref = {
[val.ret.empty] = pref_msg,
[val.ret.format] = pref_msg,
[val.ret.outofrange] =pref_msg
}
get_page_var()
if next(box.post) then
if box.post.btnSave then
local ctlmgr_save={}
local reboot=false
if (box.post.set_tr_064 == nil and g_var.tr064_enabled) or (box.post.set_tr_064 and not(g_var.tr064_enabled)) then
cmtable.save_checkbox(ctlmgr_save, "tr064:settings/enabled" , "set_tr_064")
reboot = true
end
if (box.post.upnp_activ == nil and g_var.upnp_activ) or (box.post.upnp_activ and not(g_var.upnp_activ)) then
cmtable.save_checkbox(ctlmgr_save, "box:settings/upnp/activated" , "upnp_activ")
cmtable.add_var(ctlmgr_save, "box:settings/upnp/control_activated" , "0")
end
if not general.is_ip_client() then
cmtable.save_checkbox(ctlmgr_save, "time:settings/chrony_enabled" , "time_server_activ")
cmtable.add_var(ctlmgr_save, "time:settings/ntp_server" , box.post.time_server)
end
cmtable.save_checkbox(ctlmgr_save, "box:settings/ethernet_guest_enabled" , "guest_enabled")
cmtable.save_checkbox(ctlmgr_save, "ipv6:settings/otherprefixesallowed" , "other_prefix_allowed")
cmtable.save_checkbox(ctlmgr_save, "ipv6:settings/radv_advdns" , "dnsv6_server_activ")
cmtable.add_var(ctlmgr_save, "ipv6:settings/dhcpv6d_preference" , box.post.ipv6_pref)
for i=1, config.ETH_COUNT do
local val = tonumber(box.post["eth"..tostring(i-1)])
if val and val >= 0 and val <= max_val(i) then
cmtable.add_var(ctlmgr_save, "eth"..tostring(i-1)..":settings/mode", val)
end
end
if (general.is_expert()) then
local listcount = box.query("dns_excepted_domains:settings/domain/count")
listcount = tonumber(listcount) or 0
local values = string.split(box.post.dns_rebind_list, "%s+", true)
local n = 0
for i, domain in ipairs(values) do
if #domain > 0 then
cmtable.add_var(ctlmgr_save, "dns_excepted_domains:settings/domain".. n .. "/name", domain)
n = n + 1
end
end
for i = listcount - 1, n, -1 do
cmtable.add_var(ctlmgr_save, "dns_excepted_domains:command/domain" .. i, "delete")
end
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg)
box.out(criterr)
else
if show_smarthome_broadcast() then
aha.SetExtInetIfEnabled(box.post.use_broadcast and 1 or 0)
end
if reboot then
require("webuicookie")
local saveset = {}
webuicookie.set_action_allowed_time()
cmtable.add_var(saveset, webuicookie.vars())
box.set_config(saveset)
http.redirect(href.get("/reboot.lua"))
end
end
get_page_var()
elseif box.post.btn_ipv4_address then
http.redirect(href.get('/net/boxnet.lua', 'back_to_page='..box.glob.script))
elseif box.post.btn_ipv6_address then
http.redirect(href.get('/net/boxnet_ipv6.lua', 'back_to_page='..box.glob.script))
elseif box.post.btn_ipv4_route then
http.redirect(href.get('/net/static_route_table.lua', 'back_to_page='..box.glob.script))
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
textarea {
width: 90%;
padding: 5px;
font: inherit;
resize: vertical;
}
#uiViewIpv6Pref {
width: 30px;
}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function OnInitPage() {
var bGuestDisabled = false;
var bShowIPv6 = true;
<?lua
g_lan_guest_possible = (box.query('box:settings/lan_guest_possible') == "1")
if (not g_lan_guest_possible or g_var.lan4_bridged) then
box.out( [[bGuestDisabled = true;]])
end
?>
jxl.disableNode("IpGuestControlBox", bGuestDisabled);
<?lua
if ( not config.IPV6 or not is_IPv6_enabled()) then
box.out( [[bShowIPv6 = false;]])
end
?>
jxl.display( "uiShowOtherIpv6Router", bShowIPv6);
}
function checkTr064Reboot() {
var tr064_old = <?lua box.out(tostring(g_var.tr064_enabled)) ?>;
var tr064_akt = jxl.getChecked("uiViewSetTr064");
if (tr064_akt != tr064_old) {
if (!confirm(
"{?859:216?}" +
"\n\n" +
"{?859:57?}"
)) {
return false;
}
}
return true;
}
function onNetSettingsSubmit()
{
if (!checkTr064Reboot()) {
return false;
}
<?lua
val.write_js_checks(g_val)
?>
}
ready.onReady(val.init(onNetSettingsSubmit, "btnSave", "main_form" ));
ready.onReady(OnInitPage);
</script>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<?lua href.default_submit("btnSave") ?>
<div class="close"><div class="formular small_indent">
<?lua if (config.ETH_GBIT) then
box.out([[
<div>
<h4>
{?859:257?}
</h4>
<p>
{?859:677?}
</p>
<table class="zebra" style="max-width:400px;">]])
write_head_trs()
write_radios()
box.out([[
</table>
</div>
]])
if (general.is_expert()) then box.out([[<hr>]]) end
end ?>
<div id="uiExpertFeatures" <?lua if (not general.is_expert()) then box.out([[style="display:none"]]) end ?>>
<div id="uiHomenetSharing">
<h4>
{?859:570?}
</h4>
<div>
<input type="checkbox" id="uiViewSetTr064" name="set_tr_064" <?lua if g_var.tr064_enabled then box.out('checked') end ?>>
<label for="uiViewSetTr064">{?859:511?}</label>
<p class="form_checkbox_explain">
{?859:2438?}
</p>
<p class="form_checkbox_explain">
{?859:144?}
</p>
</div>
<div>
<input type="checkbox" id="uiViewUpnpAktiv" name="upnp_activ" <?lua if g_var.upnp_activ then box.out('checked') end ?>>
<label for="uiViewUpnpAktiv">{?859:341?}</label>
<p class="form_checkbox_explain">
{?859:536?}
</p>
</div>
<?lua if show_smarthome_broadcast() then
box.out([[<div>]], "\n")
box.out([[<input type="checkbox" id="uiView_UseBroadcast" name="use_broadcast"]])
box.out(g_var.use_broadcast and [[ checked]] or "")
box.out([[>]], "\n")
box.out([[<label for="uiView_UseBroadcast">]])
box.html([[{?859:489?}]])
box.out([[</label>]], "\n")
box.out([[<p class="form_checkbox_explain">]])
box.html([[{?859:621?}]])
box.out([[</p>]], "\n")
box.out([[</div>]], "\n")
end ?>
</div>
<hr>
<div id="IpAdressControlBox" <?lua if g_var.opmode == "opmode_eth_ipclient" then box.out([[style="display:none;"]]) end?> >
<h4>
{?859:233?}
</h4>
<div >
<p>
{?859:14?}
</p>
<div class="btn_form">
<button type="submit" name="btn_ipv4_address" id="btnIPv4Address">{?859:764?}</button>
<?lua
if (is_IPv6_enabled()) then
box.out([[<button type="submit" name="btn_ipv6_address" id="btnIPv6Address">{?859:892?}</button>]])
end
?>
</div>
</div>
<hr>
</div>
<h4>
{?859:722?}
</h4>
<div >
<p>
{?859:377?}
</p>
<div class="btn_form">
<button type="submit" name="btn_ipv4_route" id="btnIPv4Route">{?859:445?}</button>
</div>
</div>
<?lua
if not general.is_ip_client() then
box.out([[
<hr>
<h4>
{?859:148?}
</h4>
<div >
<p>
{?859:528?}
</p>
<div class="formular">
<label for="uiViewTimeServerList">{?859:954?} </label>
<input type="text" maxlength="120" id="uiViewTimeServerList" name="time_server" value="]]) box.html(g_var.time_server) box.out([[">
</div>
<p>
{?859:551?}
</p>
<div class="formular">
<input type="checkbox" id="uiViewSetTimeServer" name="time_server_activ" ]]) if g_var.time_enabled then box.out('checked') end box.out([[>
<label for="uiViewSetTimeServer">{?859:940?}</label>
</div>
</div>]])
end
?>
<div id="uiShowOtherIpv6Router">
<hr>
<h4>
{?859:177?}
</h4>
<div >
<div >
<input type="checkbox" id="uiViewOtherPrefixAllowed" name="other_prefix_allowed" <?lua if g_var.otherprefixallowed then box.out('checked') end?>>
<label for="uiViewOtherPrefixAllowed">{?859:653?}</label>
</div>
<div >
<input type="checkbox" id="uiViewDNSv6Server" name="dnsv6_server_activ" <?lua if g_var.dnsv6server then box.out('checked') end?>>
<label for="uiViewDNSv6Server">{?859:955?}</label>
</div>
<div >
<p>{?859:289?}</p>
<div class="formular">
<label for="uiViewIpv6Pref">{?859:4655?}</label><input type="text" maxlength="3" id="uiViewIpv6Pref" name="ipv6_pref" value="<?lua box.html(g_var.ipv6_pref)?>">&nbsp;<span>{?859:581?}</span>
</div>
</div>
</div>
</div>
<?lua
if (general.is_expert()) then
box.out([[<hr>]])
box.out([[<div>]])
box.out([[<h4>]])
box.out([[{?859:886?}]])
box.out([[</h4>]])
box.out([[<p>]])
box.out([[{?859:504?}]])
box.out([[</p>]])
box.out([[{?859:435?}]])
box.out([[<div>]])
box.out([[<textarea id="uiDnsRebind" name="dns_rebind_list" cols="30" rows="5">]])
box.out(write_list())
box.out([[</textarea>]])
box.out([[</div>]])
box.out([[</div>]])
end
?>
</div></div>
<?lua
if ( show_buttons()) then
box.out( [[<div id="btn_form_foot">]])
box.out( [[<button type="submit" name="btnSave" id="btnSave">]]..box.tohtml([[{?txtApply?}]])..[[</button>]])
box.out( [[<button type="submit" name="btnChancel" id="btnChancel">]]..box.tohtml([[{?txtCancel?}]])..[[</button>]])
box.out( [[</div>]])
end
?>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
