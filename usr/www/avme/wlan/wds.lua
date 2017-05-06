<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_wlan_wds.html"
dofile("../templates/global_lua.lua")
require("general")
require("http")
require("cmtable")
require("val")
require("ip")
require("wlanscan")
require("net_devices")
require("menu")
if not menu.check_page("wlan", [[/wlan/wds.lua]]) then
require("http")
require("href")
http.redirect(href.get([[/wlan/wds2.lua]]))
box.end_page()
end
g_back_to_page = http.get_back_to_page( "/wlan/wds.lua" )
g_errmsg = nil
g_val = {
prog = [[
if __checked(uiViewWDS/WdsActive) then
if __radio_check(uiViewMode1/Mode,repeater) then
ipv4(uiIpaddr/ipaddr, ipaddr, zero_not_allowed, ip_error_txt)
netmask(uiIpmask/ipmask, ipmask, ip_error_txt)
ipv4(uiIpgate/ipgate, ipgate, zero_not_allowed, ip_error_txt)
ipv4(uiIpdns0/ipdns0, ipdns0, zero_not_allowed, ip_error_txt)
ipv4(uiIpdns1/ipdns1, ipdns1, zero_allowed, ip_error_txt)
not_equal_ip(uiIpaddr/ipaddr, uiIpgate/ipgate, ip_gate_error_txt)
not_equal_ip(uiIpaddr/ipaddr, uiIpdns0/ipdns0, ip_dns_error_txt)
not_equal_ip(uiIpaddr/ipaddr, uiIpdns1/ipdns1, ip_dns_error_txt)
end
if __radio_check(uiSecLevelWpa/SecLevel,wpa) then
not_empty(uiViewpskvalue/pskvalue, wpa_key_error_txt)
length(uiViewpskvalue/pskvalue, 8, 32, wpa_key_error_txt)
char_range(uiViewpskvalue/pskvalue, 32, 126, wpa_key_error_txt)
end
if __radio_check(uiSecLevelWep/SecLevel,wep) then
not_empty(uiViewWepvalue/wepvalue, wep_key_error_txt)
length(uiViewWepvalue/wepvalue, 26, 26, wep_key_error_txt)
char_range_regex(uiViewWepvalue/wepvalue, hexvalue, wep_key_error_txt)
end
end
]]
}
val.msg.wpa_key_error_txt = {
[val.ret.empty] = [[{?809:500?}]],
[val.ret.toolong] = [[{?809:875?}]],
[val.ret.tooshort] = [[{?809:971?}]],
[val.ret.outofrange] = [[{?809:6?}]]
}
val.msg.wep_key_error_txt = {
[val.ret.empty] = [[{?809:662?}]],
[val.ret.toolong] = [[{?809:704?}]],
[val.ret.tooshort] = [[{?809:352?}]],
[val.ret.outofrange] = [[{?809:619?}]]
}
val.msg.ip_error_txt = {
[val.ret.empty] = [[{?809:121?}]],
[val.ret.format] = [[{?809:694?}]],
[val.ret.outofrange] = [[{?809:465?}]],
[val.ret.outofnet] = [[{?809:551?}]],
[val.ret.thenet] = [[{?809:765?}]],
[val.ret.broadcast] = [[{?809:136?}]],
[val.ret.thebox] = [[{?809:443?}]],
[val.ret.nomask] = [[{?809:101?}]],
[val.ret.allzero] = [[{?809:668?}]],
[val.ret.notzero] = [[{?809:526?}]]
}
val.msg.ip_gate_error_txt = {
[val.ret.notdifferent] = [[{?809:616?}]]
}
val.msg.ip_dns_error_txt = {
[val.ret.notdifferent] = [[{?809:270?}]]
}
g_wan_ipdns0 = {}
g_wan_ipdns1 = {}
g_wan_ipmask = {}
g_wan_ipgate = {}
g_wan_ipaddr = {}
g_WDS_mac_master= ""
g_WDS_mac_slave = {}
g_channel = "0"
function read_box_values()
g_wan_ipdns0 = ip.quad2table(box.query('box:settings/dns0'))
g_wan_ipdns1 = ip.quad2table(box.query('box:settings/dns1'))
g_wan_ipmask = ip.quad2table(box.query('interfaces:settings/lan0/netmask'))
g_wan_ipgate = ip.quad2table(box.query('box:settings/gateway'))
g_wan_ipaddr = ip.quad2table(box.query('interfaces:settings/lan0/ipaddr'))
end
function refill_user_input_from_post()
g_wan_ipdns0 = { box.post.ipdns00, box.post.ipdns01, box.post.ipdns02, box.post.ipdns03 }
g_wan_ipdns1 = { box.post.ipdns10, box.post.ipdns11, box.post.ipdns12, box.post.ipdns13 }
g_wan_ipmask = { box.post.ipmask0, box.post.ipmask1, box.post.ipmask2, box.post.ipmask3 }
g_wan_ipgate = { box.post.ipgate0, box.post.ipgate1, box.post.ipgate2, box.post.ipgate3 }
g_wan_ipaddr = { box.post.ipaddr0, box.post.ipaddr1, box.post.ipaddr2, box.post.ipaddr3 }
end
function refill_user_input_from_get()
g_wan_ipdns0 = { box.get.ipdns00, box.get.ipdns01, box.get.ipdns02, box.get.ipdns03 }
g_wan_ipdns1 = { box.get.ipdns10, box.get.ipdns11, box.get.ipdns12, box.get.ipdns13 }
g_wan_ipmask = { box.get.ipmask0, box.get.ipmask1, box.get.ipmask2, box.get.ipmask3 }
g_wan_ipgate = { box.get.ipgate0, box.get.ipgate1, box.get.ipgate2, box.get.ipgate3 }
g_wan_ipaddr = { box.get.ipaddr0, box.get.ipaddr1, box.get.ipaddr2, box.get.ipaddr3 }
end
function check_param(name)
local s=string.find(name,"_i$")
if (s) then
return false
end
if (name=="add_mac") then
return false
end
return true
end
function get_current_mode()
local current_mode = "basis"
if (g_isRepMode) then
current_mode="repeater"
end
if (not g_wds_active) then
local state = general.get_dsl_state()
local atamode = general.is_atamode()
local nocable = box.query("box:status/hint_dsl_no_cable")
if (atamode == "1") then
current_mode="repeater"
else
if (nocable == "1") then
current_mode="repeater";
else
if (state~="HS" and state~="RTDL" and state~="SHOWTIME") then
current_mode="repeater"
end
end
end
end
return current_mode
end
if next(box.post) then
if box.post.apply then
local saveset = {}
local NextPageToShow="reload"
if (box.post.WdsActive) then
local result=val.validate(g_val)
if result == val.ret.ok then
require("string_op")
if (box.post.Mode=="basis") then
local oldMode=box.query("wlan:settings/WDS_hop")
if (oldMode=="1" and general.is_ip_client()) then
cmtable.add_var(saveset, "providerlist:settings/activeprovider", "other")
cmtable.add_var(saveset, "box:settings/opmode", "opmode_modem")
if get_current_mode() ~= "basis" then
NextPageToShow="/networkchange.lua"
end
end
cmtable.add_var(saveset, "wlan:settings/WDS_enabled","1")
cmtable.add_var(saveset, "wlan:settings/WDS_hop","0")
for i=1,4,1 do
g_WDS_mac_slave[i]="00:00:00:00:00:00"
end
local i=1
for k, v in pairs(box.post) do
local s=string.find(k,"_i$")
local pos=string.find(k,"check")
if pos==1 and s==nil then
local t=string_op.split2table(v,"§",0)
g_WDS_mac_slave[i]=t[1]
if (g_WDS_mac_slave[i]==nil) then
g_WDS_mac_slave[i]="00:00:00:00:00:00"
end
i=i+1
if (i==5) then
break;
end
end
end
for i=1,4,1 do
cmtable.add_var(saveset, "wlan:settings/WDS_mac_slave"..i-1,g_WDS_mac_slave[i])
end
elseif (box.post.Mode=="repeater") then
if get_current_mode() ~= "repeater" then
NextPageToShow="/networkchange.lua"
end
cmtable.add_var(saveset, "providerlist:settings/activeprovider", "other")
cmtable.add_var(saveset, "box:settings/opmode", "opmode_eth_ipclient")
cmtable.add_var(saveset, "wlan:settings/WDS_enabled","1")
cmtable.add_var(saveset, "wlan:settings/WDS_hop","1")
g_wan_ipaddr = ip.read_from_post("ipaddr")
g_wan_ipmask = ip.read_from_post("ipmask")
g_wan_ipgate = ip.read_from_post("ipgate")
g_wan_ipdns0 = ip.read_from_post("ipdns0")
g_wan_ipdns1 = ip.read_from_post("ipdns1")
if (g_wan_ipdns1=="") then
g_wan_ipdns1="0.0.0.0"
end
cmtable.add_var(saveset, "interfaces:settings/lan0/ipaddr", g_wan_ipaddr)
cmtable.add_var(saveset, "interfaces:settings/lan0/netmask", g_wan_ipmask)
cmtable.add_var(saveset, "box:settings/gateway", g_wan_ipgate)
cmtable.add_var(saveset, "box:settings/dns0", g_wan_ipdns0)
cmtable.add_var(saveset, "box:settings/dns1", g_wan_ipdns1)
g_WDS_mac_master="00:00:00:00:00:00"
for k, v in pairs(box.post) do
local s=string.find(k,"_i$")
local pos=string.find(k,"check")
if pos==1 and s==nil then
local t=string_op.split2table(v,"§",0)
g_WDS_mac_master=t[1]
if (g_WDS_mac_master==nil) then
g_WDS_mac_master="00:00:00:00:00:00"
end
g_channel=t[2]
break;
end
end
cmtable.add_var(saveset, "wlan:settings/WDS_mac_master",g_WDS_mac_master)
if (g_channel~="0") then
if config.WLAN.is_double_wlan then
if (tonumber(g_channel)>13) then
cmtable.add_var(saveset, "wlan:settings/channel_scnd", g_channel)
else
cmtable.add_var(saveset, "wlan:settings/channel", g_channel)
end
else
cmtable.add_var(saveset, "wlan:settings/channel", g_channel)
end
end
if config.WLAN_GUEST == 1 then
cmtable.add_var(saveset, "wlan:settings/guest_ap_enabled","0")
cmtable.add_var(saveset, "wlan:settings/guest_pskvalue", "")
cmtable.add_var(saveset, "wlan:settings/guest_encryption", "4")
end
end
local seclevel="0"
if box.post.SecLevel=="wpa" then
seclevel="3"
cmtable.add_var(saveset, "wlan:settings/WDS_key",tostring(box.post.pskvalue))
elseif box.post.SecLevel=="wep" then
seclevel="1"
if (box.query("wlan:settings/encryption")~="1") then
cmtable.add_var(saveset, "wlan:settings/key_value0",tostring(box.post.wepvalue))
cmtable.add_var(saveset, "wlan:settings/key_len0","13")
end
end
cmtable.add_var(saveset, "wlan:settings/WDS_encryption",seclevel)
cmtable.add_var(saveset, "box:settings/dhcpclient/use_static_dns","1")
cmtable.add_var(saveset, "interfaces:settings/lan0/dhcpclient","0")
cmtable.add_var(saveset, "wlan:settings/night_time_control_no_forced_off","0")
if box.query("wlan:settings/WDS_enabled")~="1" then
NextPageToShow="/networkchange.lua"
end
end
else
local oldWdsState=box.query("wlan:settings/WDS_enabled")=="1"
local oldWdsMode =box.query("wlan:settings/WDS_hop")
if (oldWdsState and oldWdsMode=="1") then
if (general.is_atamode()) then
cmtable.add_var(saveset, "providerlist:settings/activeprovider", "other")
cmtable.add_var(saveset, "box:settings/opmode", "opmode_modem")
if box.query("wlan:settings/WDS_enabled")~="0" then
NextPageToShow="/networkchange.lua"
end
end
end
cmtable.add_var(saveset, "wlan:settings/WDS_enabled","0")
end
local err=0
err, g_errmsg = box.set_config(saveset)
if err==0 then
if (NextPageToShow~="reload") then
local param = {}
param[1]="ifmode=modem"
http.redirect(href.get(NextPageToShow, unpack(param)))
end
http.redirect(href.get(g_back_to_page))
else
refill_user_input_from_post()
end
elseif box.post.add_mac then
local param = {}
local i=1
for k,v in pairs(box.post) do
if (check_param(k)) then
param[i] = k.."="..v
i=i+1
end
end
target = "/wlan/add_by_mac.lua"
local str=href.get(target, unpack(param))
http.redirect(str)
return
elseif box.post.refresh_list then
local saveset = {}
cmtable.add_var(saveset, "wlan:settings/scan_apenv","2")
local err=0
err, g_errmsg = box.set_config(saveset)
http.redirect(href.get(g_back_to_page))
return
elseif box.post.cancel then
http.redirect(href.get(g_back_to_page))
return
end
end
g_isRepMode = (box.query("wlan:settings/WDS_hop")=="1")
g_wds_active = (box.query("wlan:settings/WDS_enabled")=="1")
g_WDS_mac_master=box.query("wlan:settings/WDS_mac_master")
g_WDS_mac_slave ={box.query("wlan:settings/WDS_mac_slave0"),
box.query("wlan:settings/WDS_mac_slave1"),
box.query("wlan:settings/WDS_mac_slave2"),
box.query("wlan:settings/WDS_mac_slave3")
}
g_WDS_SecLevel = box.query("wlan:settings/WDS_encryption")
g_wlanList = wlanscan.get_wlan_scan_list()
g_ap_env_state = box.query("wlan:settings/APEnvStatus")
g_MonitorLink=[[<a href="]]..href.get("/wlan/radiochannel.lua")..[[" id="uiMonLink">{?809:614?}</a>]]
g_CurrentMode="basis"
g_CurrentMode = get_current_mode()
g_wepvalue=box.query('wlan:settings/key_value0')
g_pskvalue=box.query("wlan:settings/WDS_key")
if (g_pskvalue=="" and g_CurrentMode=="basis") then
g_pskvalue=box.query("wlan:settings/pskvalue")
end
g_CurrentEncrypt =box.query("wlan:settings/encryption")
g_CurrentSecLevel ="none"
g_is_double_wlan =false
g_active =(box.query("wlan:settings/ap_enabled")=="1")
g_channel =box.query("wlan:settings/channel")
g_used_channel =wlanscan.get_used_channel(g_wlanList,"24")
g_active_scnd =false
g_channel_scnd ="-1"
g_used_channel_scnd="-1"
if config.WLAN.is_double_wlan then
g_is_double_wlan =true
g_active_scnd =(box.query("wlan:settings/ap_enabled_scnd")=="1")
g_channel_scnd =box.query("wlan:settings/channel_scnd")
g_used_channel_scnd =wlanscan.get_used_channel(g_wlanList,"5")
end
read_box_values()
g_new_device_by_mac=""
if box.get and box.get.macstr then
g_new_device_by_mac=box.get.macstr
if (box.get.pskvalue) then
g_pskvalue =box.get.pskvalue
end
g_CurrentMode =box.tohtml(box.get.Mode)
g_wds_active =(box.get.WdsActive=="on")
g_CurrentSecLevel =box.tohtml(box.get.SecLevel)
g_WDS_SecLevel ="0"
if (g_CurrentSecLevel=="wpa") then
g_WDS_SecLevel="3"
elseif (g_CurrentSecLevel=="wep") then
g_WDS_SecLevel="1"
end
refill_user_input_from_get()
if box.get.wepvalue then
g_wepvalue=box.get.wepvalue
end
for k, v in pairs(box.get) do
local pos=string.find(k,"check")
if (pos==1 and check_param(k)) then
net_devices.check_and_add(g_wlanList,v)
end
end
end
?>
<?lua
function InitSecLevel()
if (not g_wds_active) then
if (g_CurrentEncrypt=="1") then
g_CurrentSecLevel="wep"
elseif(g_CurrentEncrypt=="2" or g_CurrentEncrypt=="3" or g_CurrentEncrypt=="4") then
g_CurrentSecLevel="wpa"
else
g_CurrentSecLevel="none"
end
else
if (g_WDS_SecLevel=="2" or g_WDS_SecLevel=="3") then
g_CurrentSecLevel="wpa"
elseif (g_WDS_SecLevel=="1") then
g_CurrentSecLevel="wep"
else
g_CurrentSecLevel="none"
end
end
end
?>
<?lua
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
function init()
InitSecLevel()
end
?>
<?lua
function IsKnownMac(isRepMode,mac)
if (isRepMode) then
if (mac==g_MacMaster) then
return true;
end
else
for i=1,#g_WDS_mac_slave,1 do
if (mac==g_WDS_mac_slave[i]) then
return true;
end
end
end
return false;
end
?>
<?lua
function GetChannelAsTxt(channel)
if (channel=="0") then
return "{?809:182?}"
end
if (channel=="-1") then
return ""
end
return tostring(channel)
end
?>
<?lua
function get_warnings()
if (not any_warnings()) then
return ""
end
local str=""
if ((g_active and g_channel=="0") or (g_active and g_channel_scnd=="0")) then
str=[[{?809:39?}]]
end
local str1=""
if (g_is_double_wlan) then
str1=str1..general.sprintf([[{?809:301?} ]],g_MonitorLink)
if (g_active_scnd and g_active) then
if ((g_channel_scnd=="0" or g_channel_scnd=="") and g_used_channel_scnd=="0") or ((g_channel=="0" or g_channel=="") and g_used_channel=="0") then
str1=[[{?809:2801?}]]
else
str1=str1..general.sprintf([[{?809:4?} ]],GetChannelAsTxt(g_used_channel))
if (tonumber(g_used_channel_scnd)>48) then
str1=str1..[[{?809:942?}]]
else
str1=str1..general.sprintf([[{?809:466?}]],GetChannelAsTxt(g_used_channel_scnd))
end
end
elseif (g_active_scnd) then
if ((g_channel_scnd=="0" or g_channel_scnd=="") and g_used_channel_scnd=="0") then
str1=[[{?809:1284?}]]
else
if (tonumber(g_used_channel_scnd)>48) then
str1=str1..[[{?809:199?}]]
else
str1=str1..general.sprintf([[{?809:697?}]],GetChannelAsTxt(g_used_channel_scnd));
end
end
else
if ((g_channel=="0" or g_channel=="") and g_used_channel=="0") then
str1=[[{?809:988?}]]
else
str1=str1..general.sprintf([[{?809:909?}]],GetChannelAsTxt(g_used_channel));
end
end
else
str1=str1..general.sprintf([[{?809:137?} ]],g_MonitorLink)
if (tonumber(g_channel)>48) then
str1=str1..[[{?809:908?}]]
else
str1=str1..general.sprintf([[{?809:496?}]],GetChannelAsTxt(g_used_channel));
end
end
local str2=general.sprintf([[{?809:687?}]],g_MonitorLink);
local htmlcode=""
if ((g_active) or (g_active_scnd)) then
htmlcode=htmlcode..[[<p>]]..str..[[</p>]]
if ((not g_active) and (g_active_scnd and tonumber(g_channel_scnd)>48)) then
local str_chan=general.sprintf([[{?809:715?}]],GetChannelAsTxt(g_used_channel_scnd))
htmlcode=htmlcode..[[<p >]]..str_chan..[[</p>]]
htmlcode=htmlcode..[[<p class="ClassHints">]]..str2..[[</p>]]
else
htmlcode=htmlcode..[[<p class="ClassHints">]]..str1..[[</p>]]
end
end
return htmlcode
end
function any_warnings()
if ((g_active and (g_channel=="0" or g_channel=="")) or (g_active_scnd and (g_channel_scnd=="0" or g_channel_scnd==""))) then
return true
end
if g_is_double_wlan then
if( g_active_scnd and tonumber(g_channel_scnd)>48) then
return true
end
else
if(tonumber(g_channel)>48) then
return true
end
end
return false
end
?>
<?lua
function get_selection_header(mode)
if (mode=="basis") then
return [[{?809:779?}]]
end
if (mode=="repeater") then
return [[{?809:458?}]]
end
return ""
end
function get_max_basis()
if config.WLAN_MADWIFI then
return "3"
end
return "4"
end
function get_max()
if (g_CurrentMode=="repeater") then
return "1"
end
return get_max_basis()
end
function get_explain_txt(mode)
local str=""
if (mode=="repeater") then
str=[[{?809:245?}]]
end
if (mode=="basis") then
str=general.sprintf([[{?809:203?}]],get_max_basis());
end
str=str..[[ {?809:759?}]]
return str
end
?>
<?lua
function no_wrong_channel()
if (g_CurrentMode=="repeater") then
return true
end
local tmp_channel=0
if (not g_wlanList) then
return false
end
for i,elem in ipairs(g_wlanList) do
if (elem.checked) then
tmp_channel=tonumber(wlanscan.get_current_channel(elem.channel))
if (g_active and g_active_scnd) then
if (tmp_channel~=tonumber(g_channel) and tmp_channel~=tonumber(g_channel_scnd)) then
return false
end
elseif (g_active_scnd) then
if (tmp_channel~=tonumber(g_channel_scnd)) then
return false
end
elseif (g_active) then
if (tmp_channel~=tonumber(g_channel))then
return false
end
end
end
end
return true
end
function get_selection_warning()
local str=[[<div id="uiWarnWrongChannel" ]]
if (no_wrong_channel()) then
str=str..[[style="display:none;"]]
end
str=str..[[><p><b>]]
if g_is_double_wlan then
if (g_active_scnd and g_active) then
str=str..general.sprintf([[{?809:343?}]],g_channel,g_channel_scnd);
elseif (g_active_scnd) then
str=str..general.sprintf([[{?809:374?}]],g_channel_scnd)
else
str=str..general.sprintf([[{?809:487?}]],g_channel)
end
else
str=str..general.sprintf([[{?809:914?}]],g_channel)
end
str=str..[[</b></p></div>]]
return str;
end
function get_wds_active()
if g_wds_active then
return [[checked="checked"]]
end
return ""
end
function get_mode_checked(mode)
if mode==g_CurrentMode then
return [[checked="checked"]]
end
return ""
end
function get_sec_level_checked(sec_level)
if sec_level==g_CurrentSecLevel then
return [[checked="checked"]]
end
return ""
end
function get_display_str(mode)
if mode==g_CurrentMode then
return ""
end
return "display:none;"
end
function get_display_str_sec(sec_level)
if g_CurrentSecLevel==sec_level then
return ""
end
return "display:none;"
end
function get_pskvalue()
if (g_wds_active) then
if (g_CurrentSecLevel=="wpa") then
return g_pskvalue
end
end
if(g_CurrentEncrypt=="2" or g_CurrentEncrypt=="3" or g_CurrentEncrypt=="4") then
return g_pskvalue
end
return ""
end
function get_display_str_wep(wep_editable)
if (g_CurrentEncrypt=="1" and wep_editable) then
return "display:none;"
end
if (g_CurrentEncrypt~="1" and not wep_editable) then
return "display:none;"
end
return ""
end
?>
<?lua
function get_wlan_devices(force)
if (g_new_device_by_mac~="") then
net_devices.check_and_add(g_wlanList,g_new_device_by_mac)
else
if (g_CurrentMode=="repeater") then
net_devices.check_and_add(g_wlanList,g_WDS_mac_master)
else
for i=1,#g_WDS_mac_slave,1 do
net_devices.check_and_add(g_wlanList,g_WDS_mac_slave[i])
end
end
end
if (g_wlanList) then
table.sort(g_wlanList, compareByRssiAndChecked)
end
return wlanscan.create_wlan_scan_table(g_wlanList,force,true,false,nil)
end
?>
<?lua
function get_apply_state()
if (g_active and g_active_scnd ) then
if (g_channel=="0" or g_channel_scnd=="0") then
return "disabled"
end
elseif (g_active and g_channel=="0") or(g_active_scnd and g_channel_scnd=="0") then
return "disabled"
end
return ""
end
?>
<?lua
function get_num_checked()
return wlanscan.get_num_of_checked(g_wlanList)
end
init()
g_ajax = false
g_startscan = false
if box.get.useajax then
g_ajax = true
g_startscan=box.get.startscan
end
if box.post.useajax then
g_ajax = true
g_startscan=box.post.startscan
end
if g_ajax then
if g_startscan then
local saveset = {}
cmtable.add_var(saveset, "wlan:settings/scan_apenv","2")
local err=0
err, g_errmsg = box.set_config(saveset)
box.out([["StartScan":1,]])
else
box.out([["StartScan":]]..tostring(box.query("wlan:settings/APEnvStatus"))..[[,]])
end
box.out([["WlanList":]])
box.out(get_wlan_devices())
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<style type="text/css">
</style>
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
<?lua
val.write_js_globals_for_ip_check()
val.write_js_error_strings()
?>
var g_wds_active =<?lua box.out(tostring(g_wds_active)) ?>;
var g_lanbridge_active ="<?lua box.out(box.query('box:settings/lanbridge/activated')) ?>";
var g_num_of_checked =<?lua box.out(get_num_checked()) ?>;
var g_active =<?lua box.out(tostring(g_active)) ?>;
var g_active_scnd =<?lua box.out(tostring(g_active_scnd)) ?>;
var g_channel =<?lua box.out(g_channel) ?>;
var g_channel_scnd =<?lua box.out(g_channel_scnd) ?>;
var g_max =<?lua box.out(get_max()) ?>;
var g_CurrentMode ="<?lua box.out(g_CurrentMode) ?>";
var g_isDoubleWlan =<?lua box.out(tostring(g_is_double_wlan)) ?>;
var g_seclevel ="<?lua box.out(g_CurrentSecLevel) ?>";
var g_ap_env_state ="<?lua box.out(tostring(g_ap_env_state)) ?>";
var g_RepeaterValue = ""
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
if (respStartScan!="1"){
zebra();
return;
}
}
}
window.setTimeout("doRequestRefreshData()", 2000);
}
}
function doRequestRefreshData(start)
{
var my_url = "/wlan/wds.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1";
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
case "0": {
doRequestRefreshData();
return true;
}
default: {
g_cbCount++;
if (g_cbCount<30) {
return false;
}
jxl.setHtml("uiWlanCurList", "<?lua box.out(get_wlan_devices(true))?>");
return true;
}
}
return false;
}
function init()
{
fc.init("uiIpaddr", 3, 'ip');
fc.init("uiIpmask", 3, 'ip');
fc.init("uiIpgate", 3, 'ip');
fc.init("uiIpdns0", 3, 'ip');
fc.init("uiIpdsn1", 3, 'ip');
jxl.disable("uiIdRenewList");
jxl.disable("uiIdShowMac");
jxl.show("uiCountKeyWpa");
jxl.show("uiCountKeyWep");
uiOnChangeWDS(g_wds_active);
EnableManualBtn()
if (g_ap_env_state!="0")
{
g_cbCount=0;
ajaxWait(g_QueryVars, "<?lua box.js(box.glob.sid) ?>", g_AktualTimeout, cbState);
}
}
function EnableManualBtn(num_of_checked)
{
if (!g_wds_active)
{
return;
}
if (!num_of_checked)
{
num_of_checked=CountChecked();
}
if (g_CurrentMode=="basis")
{
jxl.setDisabled("uiIdShowMac",(num_of_checked>=g_max))
}
else if (g_CurrentMode=="repeater")
{
jxl.setDisabled("uiIdShowMac",(num_of_checked>=1))
}
return;
}
function check_selected(num_of_checked)
{
if (num_of_checked==0)
{
var msg="{?809:195?}";
if (g_CurrentMode=="repeater")
{
msg="{?809:841?}";
}
alert(msg);
return false;
}
if (g_CurrentMode=="basis" && num_of_checked>g_max)
{
var msg=jxl.sprintf("{?809:171?}",g_max);
alert(msg);
return false;
}
else if (g_CurrentMode=="repeater" && num_of_checked>1)
{
var msg="{?809:393?}";
alert(msg);
return false;
}
return true;
}
function uiDoOnMainFormSubmit()
{
var ret;
<?lua
val.write_js_checks(g_val)
?>
if (jxl.getChecked("uiViewWDS"))
{
var num_of_checked=CountChecked();
if (!check_selected(num_of_checked))
{
return false;
}
if (g_CurrentMode=="repeater")
{
var guest_Lan_enabled="0";
var guest_ap_enabled="0";
guest_ap_enabled="<?lua box.out(box.query('wlan:settings/guest_ap_enabled')) ?>";
if ( (guest_ap_enabled=="1") || (guest_Lan_enabled == "1"))
{
var szMsg = "";
if ((guest_ap_enabled=="1") && (guest_Lan_enabled == "1")) {
szMsg = "{?809:4394?}";
}
if ((guest_ap_enabled=="0") && (guest_Lan_enabled == "1")) {
szMsg = "{?809:615?}";
}
if ((guest_ap_enabled=="1") && (guest_Lan_enabled == "0")) {
szMsg = "{?809:744?}";
}
if (!confirm(szMsg)) return;
}
var OtherMac="";
var OtherChan="";
var OtherSSID="";
var OtherEncStr="";
jxl.walkDom("uiListOfAps", "tr", function(tr) {
if (jxl.hasClass(tr, "highlight")) {
var InputField = tr.getElementsByTagName('input');
//Valueaufbau:mac,chan,encstr,ssid
var tmp=InputField[0].defaultValue;
var strArr=tmp.split("§");
OtherMac =strArr[0];
OtherChan =strArr[1];
OtherEncStr=strArr[2]; //Wird hier nicht benutzt.
OtherSSID =strArr[3]; //Sind in der SSID Kommas wird hier der Name abgeschnitten.
}
});
var OwnSSID ="<?lua box.js(box.query('wlan:settings/ssid')) ?>";
if (Number(OtherChan)>13 && g_isDoubleWlan)
{
OwnSSID="<?lua box.js(box.query('wlan:settings/ssid_scnd')) ?>";
}
if (OtherSSID!="" && OtherSSID!=OwnSSID)
{
var msg="{?809:376?}";
msg+="{?809:6158?}"+OtherSSID+"'";
msg+="{?809:497?}"+OwnSSID+"'";
msg+="{?809:240?}";
alert(msg);
}
}
doPopupWindow();
}
return true;
}
function GetIp(BaseId)
{
var ip=[];
var str="";
for (i=0;i<4;i++)
{
ip.push(jxl.getValue(BaseId+i));
}
str=ip.join(".");
return str;
}
function doPopupWindow() {
var wdsenc = g_seclevel;
var key = jxl.getValue("uiViewWepvalue");
var secondWindow = "Zweitfenster";
if ('<?lua box.query("wlan:settings/encryption") ?>'=="1")
{
key='<?lua box.out(box.query("wlan:settings/key_value0")) ?>';
}
if (g_seclevel=="wpa")
{
key = jxl.getValue("uiViewpskvalue");
}
var ipadr = GetIp("uiIpaddr");
var netmask = GetIp("uiIpmask");
var url = encodeURI("<?lua href.write('/wlan/pp_wds.lua') ?>");
url += "&seclevel="+encodeURIComponent(wdsenc);
url += "&seckey="+encodeURIComponent(key);
url += "&wds_mode="+encodeURIComponent(g_CurrentMode);
url += "&ipaddr="+encodeURIComponent(ipadr);
url += "&netmask="+encodeURIComponent(netmask);
if (g_CurrentMode=="repeater" && g_RepeaterValue!="")
{
var allData=g_RepeaterValue.split("§");
var cur_chan=parseInt(allData[1]) || 0; //Das ist der Kanal
<?lua
if config.WLAN.is_double_wlan then
box.out([[
if (cur_chan<=13)
g_channel=allData[1];
else
g_channel_scnd=allData[1];
]])
else
box.out([[g_channel=allData[1];]])
end
?>
}
url += "&channel24="+encodeURIComponent(g_channel);
<?lua
if config.WLAN.is_double_wlan then
box.out([[
url += "&channel5="+encodeURIComponent(g_channel_scnd);
var WinHeight=370;
if (g_CurrentMode=="repeater")
{
WinHeight=475;
}
]])
else
box.out([[
var WinHeight=325;
if (g_CurrentMode=="repeater")
{
WinHeight=420;
}
]])
end
?>
var ppWindow = window.open(url, secondWindow, "width=520,height="+WinHeight+",statusbar,resizable=yes");
ppWindow.focus();
}
function OnDoRefresh()
{
doRequestRefreshData(true);
return false;
}
function OnDoWDSMode(mode)
{
var oldclass=g_CurrentMode;
g_CurrentMode=mode;
if (oldclass!=g_CurrentMode)
{
jxl.removeClass("uiListOfAps",oldclass);
jxl.addClass("uiListOfAps",g_CurrentMode);
}
if (mode=="basis")
{
jxl.setText("uiViewSelectionHeader","<?lua box.js(get_selection_header('basis')) ?>");
jxl.setText("uiModeExplain","<?lua box.js(get_explain_txt('basis')) ?>");
jxl.hide("uiWlanIp");
g_max=<?lua box.out(get_max_basis())?>;
var bShowWarning=CountCheckedWithWrongChan()>0 ;
jxl.display("uiWarnWrongChannel",bShowWarning);
}
if (mode=="repeater")
{
jxl.setText("uiViewSelectionHeader","<?lua box.js(get_selection_header('repeater')) ?>");
jxl.setText("uiModeExplain","<?lua box.js(get_explain_txt('repeater')) ?>");
jxl.show("uiWlanIp");
jxl.hide("uiWarnWrongChannel");
g_max=1;
}
EnableManualBtn()
return
}
function OnDoSecLevel(SecLevel)
{
var result=true;
var ViewWpa=false;
var ViewWep=false;
var ViewNone=false;
switch (SecLevel)
{
case "wpa":
ViewWpa=true;
break;
case "wep":
ViewWep=true;
var apencr = "<?lua box.out(box.query('wlan:settings/encryption')) ?>";
var weplen = "<?lua box.out(box.query('wlan:settings/key_len0')) ?>";
if (apencr=="1" && weplen=="5") {
var mldWep64 = "{?809:83?}\x0d\x0a" +
"{?809:675?}\x0d\x0a" +
"{?809:930?}";
alert(mldWep64);
result=false;
SecLevel=g_seclevel;
ViewWep=false;
if (g_seclevel=="wpa" || g_seclevel=="wep")
{
ViewWpa=true;
jxl.setChecked("uiSecLevelWpa",true);
}
else
{
ViewNone=true;
jxl.setChecked("uiSecLevelNone",true);
}
}
break;
case "none":
ViewNone=true;
break;
}
g_seclevel=SecLevel;
jxl.display("uiSecLevelWpaDiv",ViewWpa);
jxl.display("uiSecLevelWepDiv",ViewWep);
jxl.display("uiSecLevelNoneDiv",ViewNone);
return result;
}
function OnChangeInput(value,id)
{
jxl.setText(id,value.length);
}
function uiOnChangeWDS(isChecked)
{
if (isChecked && g_lanbridge_active == "0")
{
var mldLanBridge="{?809:1?}";
alert(mldLanBridge);
return false;
}
jxl.disableNode("uiSelectMode",!isChecked);
jxl.disableNode("uiModeExplain",!isChecked);
jxl.disableNode("uiWlanDev",!isChecked);
jxl.disableNode("uiWlanIp",!isChecked);
jxl.disableNode("uiWlanSecurity",!isChecked);
if (isChecked)
{
if (!OnDoSecLevel(g_seclevel))
{
g_seclevel="wpa";
jxl.setChecked("uiSecLevelWpa",true);
}
}
return true;
}
function UncheckAll()
{
jxl.walkDom("uiListOfAps", "tr", function(tr) {
if (jxl.hasClass(tr, "highlight"))
{
jxl.removeClass(tr,"highlight");
jxl.walkDom(tr, "input", function(checkbox) {
checkbox.checked=false;
});
}
});
}
function CountCheckedWithWrongChan()
{
var count=0;
jxl.walkDom("uiListOfAps", "tr", function(tr) {
if (jxl.hasClass(tr, "highlight") && jxl.hasClass(tr, "badchannel")) {
count++;
}
});
return count;
}
function CountChecked()
{
var count=0;
jxl.walkDom("uiListOfAps", "tr", function(tr) {
if (jxl.hasClass(tr, "highlight")) {
count++;
}
});
return count;
}
function ShowWarning(elem)
{
if (g_CurrentMode=="repeater")
{
return;
}
var msgtxt ="";
var chantxt="";
var t=elem.value.split("§");
var device_chan=t[1];
<?lua
if config.WLAN.is_double_wlan then
box.out([[
if (g_active_scnd && g_active)
{
if (g_channel!=device_chan && g_channel_scnd!=device_chan)
{
chantxt=jxl.sprintf("{?809:598?}",g_channel,g_channel_scnd);
}
}
else if (g_active_scnd)
{
if (g_channel_scnd!=device_chan)
{
chantxt=jxl.sprintf("{?809:863?}",g_channel_scnd);
}
}
else if (g_active)
{
if (g_channel!=device_chan)
{
chantxt=jxl.sprintf("{?809:6062?}",g_channel);
}
}
else
{
//gar keiner aktiv?
}
]])
else
box.out([[
if (g_channel!=device_chan)
{
chantxt=jxl.sprintf("{?809:538?}",g_channel);
}
]])
end
?>
if (chantxt!="")
{
msgtxt="{?809:821?}";
msgtxt+=chantxt;
msgtxt+=jxl.sprintf("{?809:889?}",device_chan);
msgtxt+="{?809:237?}";
alert(msgtxt);
}
}
function OnChangeActive(elem,n)
{
var num_of_checked=CountChecked();
if (elem.checked)
{
num_of_checked++;
if (!check_selected(num_of_checked))
{
jxl.removeClass("uiViewRow"+n,"highlight");
return false;
}
ShowWarning(elem);
}
else
{
num_of_checked--;
}
if (elem.checked)
{
jxl.addClass("uiViewRow"+n,"highlight");
}
else
{
jxl.removeClass("uiViewRow"+n,"highlight");
}
EnableManualBtn(num_of_checked);
g_RepeaterValue=elem.value;
var bShowWarning=g_CurrentMode=="basis" && CountCheckedWithWrongChan()>0;
jxl.display("uiWarnWrongChannel",bShowWarning);
return true;
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div id="content">
<div id="uiViewAll" style="">
<p>
{?809:44?}
</p>
<hr>
<h4>
{?809:148?}
</h4>
<ul>
<li>
{?809:45?}<br>
<?lua
if config.WLAN_WPS then
box.out(general.sprintf([[{?809:561?}]],[[<a class="JumpLink" href="]]..href.get("/wlan/wps.lua")..[[">]],[[</a>]]))
end
?>
</li>
<li>
<?lua box.out(general.sprintf([[{?809:387?}]],[[<a class="JumpLink" href="]]..href.get("/wlan/radiochannel.lua")..[[">]],[[</a>]])) ?>
</li>
<li>
{?809:433?}
</li>
</ul>
<hr>
<?lua
box.out(get_warnings())
?>
<div id="uiViewAllWds" style="<?lua if (any_warnings()) then box.out('display:none;') end ?>">
<p id="uiViewChangeWDS" >
<input type="checkbox" onclick="return uiOnChangeWDS(this.checked);" id="uiViewWDS" name="WdsActive" <?lua box.out(get_wds_active())?>><label for="uiViewWDS">{?809:757?}</label>
</p>
<hr>
<h4>{?809:86?}</h4>
<div id="uiSelectMode" class="formular small_indent">
<input type="radio" onclick="OnDoWDSMode('basis')" name="Mode" value="basis" id="uiViewMode0" <?lua box.out(get_mode_checked("basis")) ?>>
<label for="uiViewMode0">{?809:944?}</label>
<p class="form_input_explain">{?809:712?}</p>
<input type="radio" onclick="OnDoWDSMode('repeater')" name="Mode" value="repeater" id="uiViewMode1" <?lua box.out(get_mode_checked("repeater")) ?>>
<label for="uiViewMode1">{?809:247?}</label>
<p class="form_input_explain">{?809:738?}</p>
</div>
<div class="blue_separator_back">
<h2 id="uiViewSelectionHeader"><?lua box.out(get_selection_header(g_CurrentMode)) ?></h2>
</div>
<p id="uiModeExplain"><?lua box.out(get_explain_txt(g_CurrentMode)) ?></p>
<div id="uiWlanDev">
<h4>
{?809:986?}
</h4>
<div id="uiWlanListDiv">
<div id="uiWlanCurList">
<?lua box.out(get_wlan_devices()) ?>
</div>
<?lua box.out(get_selection_warning()) ?>
<div class="rightBtn">
<p >
<input type="submit" id="uiIdRenewList" name="refresh_list" onclick="return OnDoRefresh();" value="{?809:173?}" >
</p>
<div>
<input type="submit" id="uiIdShowMac" name="add_mac" value="{?809:861?}" >
</div>
<p class="explainBtn">
{?809:272?}
</p>
<div class="clear_float"></div>
</div>
</div>
</div>
<div id="uiWlanIp" style="<?lua box.out(get_display_str('repeater')) ?>">
<hr>
<h4>{?809:593?}</h4>
<div >
<p>{?809:901?}</p>
<div class="formular">
<div class="group" id="uiIpaddr">
<label for="uiViewWanIpIpaddr">{?809:229?} (1)</label>
<input type="text" size="3" maxlength="3" id="uiIpaddr0" name="ipaddr0" value="<?lua box.html(g_wan_ipaddr[1]) ?>" <?lua val.write_attrs(g_val, 'uiIpaddr0', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpaddr1" name="ipaddr1" value="<?lua box.html(g_wan_ipaddr[2]) ?>" <?lua val.write_attrs(g_val, 'uiIpaddr1', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpaddr2" name="ipaddr2" value="<?lua box.html(g_wan_ipaddr[3]) ?>" <?lua val.write_attrs(g_val, 'uiIpaddr2', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpaddr3" name="ipaddr3" value="<?lua box.html(g_wan_ipaddr[4]) ?>" <?lua val.write_attrs(g_val, 'uiIpaddr3', 'ip') ?> />
<?lua val.write_html_msg(g_val, "uiIpaddr0", "uiIpaddr1", "uiIpaddr2", "uiIpaddr3") ?>
</div>
<div class="group" id="uiIpmask">
<label for="uiViewWanIpNetmask">{?809:161?}</label>
<input type="text" size="3" maxlength="3" id="uiIpmask0" name="ipmask0" value="<?lua box.html(g_wan_ipmask[1]) ?>" <?lua val.write_attrs(g_val, 'uiIpmask0', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpmask1" name="ipmask1" value="<?lua box.html(g_wan_ipmask[2]) ?>" <?lua val.write_attrs(g_val, 'uiIpmask1', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpmask2" name="ipmask2" value="<?lua box.html(g_wan_ipmask[3]) ?>" <?lua val.write_attrs(g_val, 'uiIpmask2', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpmask3" name="ipmask3" value="<?lua box.html(g_wan_ipmask[4]) ?>" <?lua val.write_attrs(g_val, 'uiIpmask3', 'ip') ?> />
<?lua val.write_html_msg(g_val, "uiIpmask0", "uiIpmask1", "uiIpmask2", "uiIpmask3") ?>
</div>
<div class="group" id="uiIpgate">
<label for="uiViewWanIpGateway">{?809:260?} (2)</label>
<input type="text" size="3" maxlength="3" id="uiIpgate0" name="ipgate0" value="<?lua box.html(g_wan_ipgate[1]) ?>" <?lua val.write_attrs(g_val, 'uiIpgate0', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpgate1" name="ipgate1" value="<?lua box.html(g_wan_ipgate[2]) ?>" <?lua val.write_attrs(g_val, 'uiIpgate1', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpgate2" name="ipgate2" value="<?lua box.html(g_wan_ipgate[3]) ?>" <?lua val.write_attrs(g_val, 'uiIpgate2', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpgate3" name="ipgate3" value="<?lua box.html(g_wan_ipgate[4]) ?>" <?lua val.write_attrs(g_val, 'uiIpgate3', 'ip') ?> />
<?lua val.write_html_msg(g_val, "uiIpgate0", "uiIpgate1", "uiIpgate2", "uiIpgate3") ?>
</div>
<div class="group" id="uiIpdns0">
<label for="uiViewWanIpDns0">{?809:93?} (2)</label>
<input type="text" size="3" maxlength="3" id="uiIpdns00" name="ipdns00" value="<?lua box.html(g_wan_ipdns0[1]) ?>" <?lua val.write_attrs(g_val, 'uiIpdns00', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpdns01" name="ipdns01" value="<?lua box.html(g_wan_ipdns0[2]) ?>" <?lua val.write_attrs(g_val, 'uiIpdns01', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpdns02" name="ipdns02" value="<?lua box.html(g_wan_ipdns0[3]) ?>" <?lua val.write_attrs(g_val, 'uiIpdns02', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpdns03" name="ipdns03" value="<?lua box.html(g_wan_ipdns0[4]) ?>" <?lua val.write_attrs(g_val, 'uiIpdns03', 'ip') ?> />
<?lua val.write_html_msg(g_val, "uiIpdns00", "uiIpdns01", "uiIpdns02", "uiIpdns03") ?>
</div>
<div class="group" id="uiIpdsn1">
<label for="uiViewWanIpDns1">{?809:201?} (2)</label>
<input type="text" size="3" maxlength="3" id="uiIpdns10" name="ipdns10" value="<?lua box.html(g_wan_ipdns1[1]) ?>" <?lua val.write_attrs(g_val, 'uiIpdns10', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpdns11" name="ipdns11" value="<?lua box.html(g_wan_ipdns1[2]) ?>" <?lua val.write_attrs(g_val, 'uiIpdns11', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpdns12" name="ipdns12" value="<?lua box.html(g_wan_ipdns1[3]) ?>" <?lua val.write_attrs(g_val, 'uiIpdns12', 'ip') ?> /> .
<input type="text" size="3" maxlength="3" id="uiIpdns13" name="ipdns13" value="<?lua box.html(g_wan_ipdns1[4]) ?>" <?lua val.write_attrs(g_val, 'uiIpdns13', 'ip') ?> />
<?lua val.write_html_msg(g_val, "uiIpdns10", "uiIpdns11", "uiIpdns12", "uiIpdns13") ?>
</div>
<div>
<span>{?809:718?}</span>
</div>
<div>
<span>{?809:224?}</span>
</div>
</div>
</div>
</div>
<div id="uiWlanSecurity" style="">
<hr>
<h4>{?809:474?}</h4>
<div>
<p>{?809:798?}</p>
<div class="formular grid">
<div>
<input type="radio" onclick="return OnDoSecLevel('wpa');" name="SecLevel" value="wpa" id="uiSecLevelWpa" <?lua box.out(get_sec_level_checked('wpa')) ?>>&nbsp;<label for="uiSecLevelWpa">{?809:273?}</label>
<span >{?809:984?}</span>
</div>
<div>
<input type="radio" onclick="return OnDoSecLevel('wep');" name="SecLevel" value="wep" id="uiSecLevelWep" <?lua box.out(get_sec_level_checked('wep')) ?>>&nbsp;<label for="uiSecLevelWep">{?809:493?}</label>
</div>
<div>
<input type="radio" onclick="return OnDoSecLevel('none');" name="SecLevel" value="none" id="uiSecLevelNone" <?lua box.out(get_sec_level_checked('none')) ?>>&nbsp;<label for="uiSecLevelNone">{?809:647?}</label>
<span>{?809:823?}</span>
</div>
</div>
<div id="uiSecLevelWpaDiv" style="<?lua box.out(get_display_str_sec('wpa')) ?>">
<p>{?809:12?}</p>
<div class="formular">
<p><label for="uiViewpskvalue">{?809:408?}</label>&nbsp;<input type="text" size="40" maxlength="32" name="pskvalue" id="uiViewpskvalue" onkeyup="OnChangeInput(this.value,'uiDezKeyWpa')" value="<?lua box.html(get_pskvalue()) ?>">&nbsp;({?809:691?})</p>
<div class="form_input_note cnt_char" style="display:none;" id="uiCountKeyWpa" ><span id="uiDezKeyWpa"><?lua box.out(#get_pskvalue()) ?></span> {?gNumOfChars?}</div>
</div>
<p>{?809:324?} {?809:805?}</p>
</div>
<div id="uiSecLevelWepDiv" style="<?lua box.out(get_display_str_sec('wep')) ?>">
<div id="uiWepEditable" style="<?lua box.out(get_display_str_wep(true)) ?>">
<p class="WarnMsgBold" style="">{?809:604?}</p>
<p>{?809:63?}</p>
<p>{?809:590?}</p>
<div class="formular">
<label for="uiViewWepvalue">{?809:702?}</label>&nbsp;<input type="text" size="30" maxlength="26" name="wepvalue" value="<?lua box.html(g_wepvalue) ?>" id="uiViewWepvalue" onkeyup="OnChangeInput(this.value,'uiDezKeyWep')">&nbsp;<span>{?809:721?}</span>
<div class="form_input_note cnt_char" style="display:none;" id="uiCountKeyWep" ><span id="uiDezKeyWep"><?lua box.out(#g_wepvalue) ?></span> {?gNumOfChars?}</div>
</div>
</div>
<div id="uiWepFixed" style="<?lua box.out(get_display_str_wep(false)) ?>">
<p ><?lua box.out(general.sprintf([[{?809:713?}]],[[<a class="JumpLink" href="]]..href.get("/wlan/encrypt.lua")..[[">]],[[</a>]])) ?></p>
<p >{?809:150?}&nbsp;<?lua box.out(box.query("wlan:settings/key_value0")) ?></p>
</div>
</div>
<div id="uiSecLevelNoneDiv" style="<?lua box.out(get_display_str_sec('none'))?>">
<p class="WarnMsgBold" style="">{?809:886?}</p>
<p >{?809:426?}</p><br>
<p >{?809:397?}
</div>
</div>
</div>
<?lua
if g_errmsg and string.len(g_errmsg)>0 then
box.out([[<p class="form_input_note ErrorMsg">]])
box.html(g_errmsg)
box.out([[</p>]])
end
?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" id="uiViewMAC00" value="" disabled>
<input type="hidden" id="uiViewMAC01" value="" disabled>
<input type="hidden" id="uiViewMAC02" value="" disabled>
<input type="hidden" id="uiViewMAC03" value="" disabled>
<input type="hidden" id="uiViewMAC10" value="" disabled>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" id="uiApply" name="apply" <?lua box.out(get_apply_state())?>>{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
