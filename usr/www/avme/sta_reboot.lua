<?lua
--[[
Datei Name: /sta_reboot.lua
Datei Beschreibung:
]]
g_page_type = "no_menu"
g_page_title = box.tohtml([[{?1699:305?}]])
------------------------------------------------------------------------------------------------------------>
dofile("../templates/global_lua.lua")
require("general")
require("cmtable")
require("val")
require("ip")
require("net_devices")
require("http")
require("webuicookie")
box.post=box.get
g_errcode = 0
g_errmsg = nil
g_saveset ={}
g_isAssi = (box.get.HTMLConfigAssiTyp=="normal" or (box.get.HTMLConfigAssiTyp=="first"))
g_hasNoPwd = false
--Validierungen
check_encrpyt=[[
if __radio_check(uiSecLevelWpa/SecLevel,wpa) then
not_empty(uiViewpskvalue/pskvalue, wpa_key_error_txt)
length(uiViewpskvalue/pskvalue, 8, 63, wpa_key_error_txt)
char_range(uiViewpskvalue/pskvalue, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
no_end_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
end
if __radio_check(uiSecLevelWep/SecLevel,wep) then
not_empty(uiViewWepvalue/wepvalue, wep_key_error_txt)
length(uiViewWepvalue/wepvalue, 26, 26, wep_key_error_txt)
char_range_regex(uiViewWepvalue/wepvalue, hexvalue, wep_key_error_txt)
end
]]
check_pwd=[[
if __checked(uiViewUsePassword/use_pwd) then
not_empty(uiViewPassword/pwd, pwd_error_txt)
char_range(uiViewPassword/pwd, 32, 126, pwd_error_txt)
end
]]
check_hidden=[[
if __value_equal(uiCurHidden/hidden,1) then
not_empty(uiView_hiddenSSID/hiddenSSID, ssid_error_txt)
no_lead_char(uiView_hiddenSSID/hiddenSSID,32,ssid_error_txt)
no_end_char(uiView_hiddenSSID/hiddenSSID,32,ssid_error_txt)
end
]]
check_dhcp_hostmanu=[[
if __radio_check(uiDhcpManu/dhcp_host,manu) then
ipv4(uiIpaddr/ipaddr, ipaddr, zero_not_allowed, ip_error_txt)
netmask(uiIpmask/ipmask, ipmask, ip_error_txt)
ipv4(uiIpgate/ipgate, ipgate, zero_not_allowed, ip_error_txt)
ipv4(uiIpdns0/ipdns0, ipdns0, zero_not_allowed, ip_error_txt)
ipv4(uiIpdns1/ipdns1, ipdns1, zero_allowed, ip_error_txt)
not_equal_ip(uiIpaddr/ipaddr, uiIpgate/ipgate, ip_gate_error_txt)
not_equal_ip(uiIpaddr/ipaddr, uiIpdns0/ipdns0, ip_dns_error_txt)
not_equal_ip(uiIpaddr/ipaddr, uiIpdns1/ipdns1, ip_dns_error_txt)
end
]]
check_ssid=[[
not_empty(uiView_SSID/SSID, wpa_key_error_txt)
no_lead_char(uiView_SSID/SSID,32,wpa_key_error_txt)
no_end_char(uiView_SSID/SSID,32,wpa_key_error_txt)
if __value_equal(uiViewWpaMods/wpa_modus,wpa) then
not_empty(uiViewWpaKey/wpa_key, wpa_key_error_txt)
length(uiViewWpaKey/wpa_key, 8, 63, wpa_key_error_txt)
char_range(uiViewWpaKey/wpa_key, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewWpaKey/wpa_key,32,wpa_key_error_txt)
no_end_char(uiViewWpaKey/wpa_key,32,wpa_key_error_txt)
end
if __value_equal(uiViewWpaMods/wpa_modus,wpa2) then
not_empty(uiViewWpaKey/wpa_key, wpa_key_error_txt)
length(uiViewWpaKey/wpa_key, 8, 63, wpa_key_error_txt)
char_range(uiViewWpaKey/wpa_key, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewWpaKey/wpa_key,32,wpa_key_error_txt)
no_end_char(uiViewWpaKey/wpa_key,32,wpa_key_error_txt)
end
if __value_equal(uiViewWpaMods/wpa_modus,wpamixed) then
not_empty(uiViewWpaKey/wpa_key, wpa_key_error_txt)
length(uiViewWpaKey/wpa_key, 8, 63, wpa_key_error_txt)
char_range(uiViewWpaKey/wpa_key, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewWpaKey/wpa_key,32,wpa_key_error_txt)
no_end_char(uiViewWpaKey/wpa_key,32,wpa_key_error_txt)
end
]]
g_val = {
prog = [[
if __radio_check(ui_wlan_bridge_radio/rep_mode,wlan_bridge) then ]]..
check_encrpyt..
check_hidden..[[
end
if __radio_check(ui_lan_bridge_radio/rep_mode,lan_bridge) then ]]..
check_dhcp_hostmanu..
check_ssid..[[
end
]]
}
if (g_isAssi) then
if (g_isFirst and g_hasNoPwd) then
g_val = {
prog = [[]]..
check_pwd..
check_encrpyt..
check_hidden..[[
]]
}
else
g_val = {
prog = [[]]..
check_encrpyt..
check_hidden..[[
]]
}
end
end
--Fehlermeldungen für die Validierungen
val.msg.pwd_error_txt = {
[val.ret.empty] = [[{?1699:377?}]],
[val.ret.different] = [[{?1699:18?}]],
[val.ret.outofrange] = [[{?1699:981?}]]
}
val.msg.wpa_key_error_txt = {
[val.ret.empty] = [[{?1699:843?}]],
[val.ret.toolong] = [[{?1699:884?}]],
[val.ret.tooshort] = [[{?1699:637?}]],
[val.ret.outofrange] = [[{?1699:826?}]],
[val.ret.leadchar] = [[{?1699:717?}]],
[val.ret.endchar] = [[{?1699:536?}]]
}
val.msg.error_host_txt = {
[val.ret.empty] = [[{?1699:772?}]],
[val.ret.toolong] = [[{?1699:1616?}]],
[val.ret.tooshort] = [[{?1699:914?}]],
[val.ret.outofrange] = [[{?1699:389?}]]
}
val.msg.wep_key_error_txt = {
[val.ret.empty] = [[{?1699:335?}]],
[val.ret.toolong] = [[{?1699:357?}]],
[val.ret.tooshort] = [[{?1699:15?}]],
[val.ret.outofrange] = [[{?1699:920?}]]
}
val.msg.ip_error_txt = {
[val.ret.empty] = [[{?1699:140?}]],
[val.ret.format] = [[{?1699:391?}]],
[val.ret.outofrange] = [[{?1699:554?}]],
[val.ret.outofnet] = [[{?1699:770?}]],
[val.ret.thenet] = [[{?1699:581?}]],
[val.ret.broadcast] = [[{?1699:315?}]],
[val.ret.thebox] = [[{?1699:764?}]],
[val.ret.nomask] = [[{?1699:710?}]],
[val.ret.allzero] = [[{?1699:549?}]],
[val.ret.notzero] = [[{?1699:927?}]]
}
val.msg.ip_gate_error_txt = {
[val.ret.notdifferent] = [[{?1699:334?}]]
}
val.msg.ip_dns_error_txt = {
[val.ret.notdifferent] = [[{?1699:682?}]]
}
val.msg.ssid_error_txt = {
[val.ret.empty] = [[{?1699:638?}]],
[val.ret.toolong] = [[{?1699:63?}]],
[val.ret.leadchar] = [[{?1699:52?}]],
[val.ret.endchar] = [[{?1699:619?}]]
}
g_rep_mode=general.get_bridge_mode()
g_ssid = ""
g_ssid_scnd = ""
g_hostname = ""
g_CurrentSecLevel = ""
g_mac = ""
g_mac_scnd = ""
g_wepvalue = ""
g_pskvalue = ""
g_hidden_ssid = false
g_hidden_ssid_scnd= false
g_wan_ipaddr = {}
g_wan_ipmask = {}
g_wan_ipgate = {}
g_wan_ipdns0 = {}
g_wan_ipdns1 = {}
g_is_double_wlan = config.WLAN.is_double_wlan
function read_from_post()
g_hostname = ""
if box.post.dhcp_host=="auto" then
g_hostname = box.post.hostname
end
g_wan_ipdns0 = ""
g_wan_ipdns1 = ""
g_wan_ipmask = ""
g_wan_ipgate = ""
g_wan_ipaddr = ""
if box.post.dhcp_host=="manu" then
g_wan_ipdns0 = ip.read_from_post("ipdns0")
g_wan_ipdns1 = ip.read_from_post("ipdns1")
g_wan_ipmask = ip.read_from_post("ipmask")
g_wan_ipgate = ip.read_from_post("ipgate")
g_wan_ipaddr = ip.read_from_post("ipaddr")
end
g_mac = box.post.mac
g_hidden_ssid = box.post.hidden or false
g_hidden_ssid_scnd= box.post.hidden_scnd or false
g_pskvalue = box.post.pskkey
g_pskvalue_scnd = box.post.pskkey_scnd
g_wepvalue = box.post.wepvalue
if (box.post.is_assi~="1") then
g_rep_mode = box.post.rep_mode
else
g_rep_mode = "wlan_bridge"
end
g_CurrentSecLevel = box.post.seclevel
g_ssid = box.post.ssid
if (box.post.hiddenSSID) then
g_ssid = box.post.hiddenSSID
end
if g_is_double_wlan then
g_mac_scnd = box.post.mac_scnd
g_ssid_scnd = box.post.ssid_scnd
if (box.post.hiddenSSID_scnd) then
g_ssid_scnd = box.post.hiddenSSID_scnd
end
end
end
if box.post and box.post.apply then
local result=val.validate(g_val)
if result== val.ret.ok then
read_from_post()
if box.post.router=="fbox" then
webuicookie.set("rep_routertype", "1")
else
webuicookie.set("rep_routertype", "0")
end
cmtable.add_var(g_saveset, webuicookie.vars())
if (g_rep_mode=="wlan_bridge") then
if (box.post.pwd and g_isFirst and g_hasNoPwd) then
cmtable.add_var(g_saveset,"security:settings/password",box.post.pwd)
cmtable.add_var(g_saveset,"login:command/password",box.post.pwd)
end
cmtable.add_var(g_saveset, "rext:settings/dhcp","1")
cmtable.add_var(g_saveset, "rext:settings/apmode","0")
cmtable.add_var(g_saveset, "wlan:settings/bridge_mode","bridge-wlan")
cmtable.add_var(g_saveset, "wlan:settings/STA_mac_master", g_mac)
cmtable.add_var(g_saveset, "wlan:settings/STA_ssid", g_ssid)
if g_mac~="00:00:00:00:00:00" then
cmtable.add_var(g_saveset, "wlan:settings/STA_configured","1")
else
cmtable.add_var(g_saveset, "wlan:settings/STA_configured","0")
end
cmtable.add_var(g_saveset, "wlan:settings/STA_encryption",net_devices.convert_enc_to_num(g_CurrentSecLevel))
cmtable.add_var(g_saveset, "wlan:settings/STA_mode","0")
if g_is_double_wlan then
cmtable.add_var(g_saveset, "wlan:settings/STA_mac_master_scnd", g_mac_scnd)
cmtable.add_var(g_saveset, "wlan:settings/STA_ssid_scnd", g_ssid_scnd)
if g_mac_scnd~="00:00:00:00:00:00" then
cmtable.add_var(g_saveset, "wlan:settings/STA_configured_scnd","1")
else
cmtable.add_var(g_saveset, "wlan:settings/STA_configured_scnd","0")
end
cmtable.add_var(g_saveset, "wlan:settings/STA_encryption_scnd",net_devices.convert_enc_to_num(g_CurrentSecLevel))
end
if config.GUI_IS_POWERLINE then
cmtable.save_checkbox(g_saveset, "wlan:settings/guest_ap_auto_update", "guest_ap_update")
end
if (g_CurrentSecLevel~="wep" and g_CurrentSecLevel~="none") then
cmtable.add_var(g_saveset, "wlan:settings/STA_pskvalue", g_pskvalue)
if g_is_double_wlan then
if g_pskvalue_scnd and g_pskvalue_scnd ~= "" then
cmtable.add_var(g_saveset, "wlan:settings/STA_pskvalue_scnd", g_pskvalue_scnd)
else
cmtable.add_var(g_saveset, "wlan:settings/STA_pskvalue_scnd", g_pskvalue)
end
end
end
if (g_CurrentSecLevel=="wep") then
----------------------------------------------------------------------
-- WEP Key speichern, wir nutzen immer nur den ersten.
----------------------------------------------------------------------
cmtable.add_var(g_saveset, "wlan:settings/STA_key_id","0")
cmtable.add_var(g_saveset, "wlan:settings/STA_key_value0",g_wepvalue)
cmtable.add_var(g_saveset, "wlan:settings/STA_key_len0",tostring(#g_wepvalue/2))
end
else
cmtable.add_var(g_saveset, "rext:settings/apmode","1")
cmtable.add_var(g_saveset, "wlan:settings/STA_configured","0")
if g_is_double_wlan then
cmtable.add_var(g_saveset, "wlan:settings/STA_configured_scnd", "0")
end
if (g_rep_mode=="plc_bridge") then
cmtable.add_var(g_saveset, "wlan:settings/bridge_mode","bridge-plc")
else
cmtable.add_var(g_saveset, "wlan:settings/bridge_mode","bridge-lan")
end
if (box.post.dhcp_host=="auto") then
cmtable.add_var(g_saveset, "rext:settings/dhcp","1")
else
cmtable.add_var(g_saveset, "rext:settings/dhcp","0")
cmtable.add_var(g_saveset, "rext:settings/first_dns", g_wan_ipdns0)
if (g_wan_ipdns1~="0.0.0.0") then
cmtable.add_var(g_saveset, "rext:settings/second_dns", g_wan_ipdns1)
else
cmtable.add_var(g_saveset, "rext:settings/second_dns", g_wan_ipdns0)
end
cmtable.add_var(g_saveset, "rext:settings/netmask", g_wan_ipmask)
cmtable.add_var(g_saveset, "rext:settings/gateway", g_wan_ipgate)
cmtable.add_var(g_saveset, "rext:settings/ipaddr", g_wan_ipaddr)
end
cmtable.add_var(g_saveset, "wlan:settings/ssid", g_ssid)
if g_is_double_wlan then
cmtable.add_var(g_saveset, "wlan:settings/ssid_scnd", g_ssid_scnd)
end
cmtable.add_var(g_saveset, "wlan:settings/pskvalue", g_pskvalue)
cmtable.add_var(g_saveset, "wlan:settings/encryption", net_devices.convert_enc_to_num(g_CurrentSecLevel))
end
end
else
--Auruf ohne Parameter!
end
function do_reboot()
if box.get.doit then
box.set_config({{
name="logic:command/reboot", value="1"
}})
end
end
function get_ssid()
--local str=box.query("wlan:settings/STA_ssid")
--if (g_rep_mode=="lan_bridge") then
-- str=box.query("wlan:settings/ssid")
--end
--return str
return g_ssid
end
function get_encrypt()
local names = {"{?1699:690?}","WEP","WPA","WPA2","WPA+WPA2"}
--local enc = tonumber(box.query('wlan:settings/STA_encryption',0)) + 1
--if (g_rep_mode=="lan_bridge") then
-- enc=tonumber(box.query('wlan:settings/encryption',0)) + 1
--end
--if (enc <= #names) then
-- str = names[enc]
--end
--return str
local enc =tonumber(net_devices.convert_enc_to_num(g_CurrentSecLevel))+1
local str = ""
if (enc <= #names) then
str = names[enc]
end
return str
end
function get_key()
--local enc = tonumber(box.query('wlan:settings/STA_encryption',0))
--if (g_rep_mode=="lan_bridge") then
-- enc=tonumber(box.query('wlan:settings/encryption',0))
--end
--local str = box.query('wlan:settings/STA_key_value')
--if (enc >= 1) then
-- if (g_rep_mode=="lan_bridge") then
-- str = box.query('wlan:settings/pskvalue')
-- else
-- if (enc==1) then
-- str = box.query('wlan:settings/STA_key_value0')
-- else
-- str = box.query('wlan:settings/STA_pskvalue')
-- end
-- end
--end
--return str
return g_pskvalue
end
function write_repeater_mode()
local str=[[{?1699:670?}]]
if (g_rep_mode=="lan_bridge") then
str=[[{?1699:840?}]]
end
if g_is_double_wlan then
str = str..[[
<table class="zebra" >
<tr>
<td>{?1699:601?}</td>
<td><strong>]]..box.tohtml(get_ssid())..[[</strong></td>
</tr>
<tr>
<td>{?1699:610?}</td>
<td><strong>]]..box.tohtml(g_ssid_scnd)..[[</strong></td>
</tr>
<tr>
<td>{?1699:431?}</td>
<td><strong>]]..box.tohtml(get_encrypt())..[[</strong></td>
</tr>
<tr>
<td>{?1699:992?}</td>
<td><strong>]]..box.tohtml(get_key())..[[</strong></td>
</tr>
</table>
]]
else
str = str..[[
<table class="zebra" >
<tr>
<td>{?1699:925?}</td>
<td><strong>]]..box.tohtml(get_ssid())..[[</strong></td>
</tr>
<tr>
<td>{?1699:205?}</td>
<td><strong>]]..box.tohtml(get_encrypt())..[[</strong></td>
</tr>
<tr>
<td>{?1699:946?}</td>
<td><strong>]]..box.tohtml(get_key())..[[</strong></td>
</tr>
</table>
]]
end
box.out(str)
end
function write_repeater_explain()
local str=[[{?1699:983?} ]]
if (g_rep_mode=="lan_bridge") then
str=[[{?1699:295?}]]
else
str=str..[[{?1699:572?}]]
end
str=str..[[ ]]
str=str..general.sprintf([[{?1699:831?}]],[[<a href='http://fritz.repeater'>]],[[</a>]])
box.out(str)
end
function do_save()
if (g_saveset) then
g_errcode, g_errmsg = box.set_config(g_saveset)
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript">
function init() {
jxl.hide("btn_form_foot");
jxl.setHtml("forward",
"<p class=\"waitimg\"><img src=\"/css/default/images/wait.gif\"></p>"+
"<p>{?1699:430?}</p>");
//maximal 5 mal 5 Sekunden warten. Eine eigene Callback brauchen wir nicht.
ajaxWaitForBox(0,5);
}
window.onload = init;
</script>
<?include "templates/page_head.html" ?>
<div>
<p>{?1699:147?}</p>
<div style="width:100%;text-align:center;padding-top:10px;padding-bottom:20px;">
<img src="/css/default/images/ok.gif" alt="Ok">
</div>
<p><?lua write_repeater_mode() ?></p>
<p>{?1699:812?}</p>
<p>
{?1699:913?}
{?1699:538?}
</p>
<div id="forward">
<p>{?1699:92?}</p>
</div>
</div>
<form action="/home/home.lua" method="GET">
<div id="btn_form_foot">
<button type="submit">{?txtToOverview?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
<?lua do_save() ?>
