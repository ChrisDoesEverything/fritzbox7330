--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
require("general")
require("config")
require"umts"
function is_Dsl_Encaps_Mode1()
local result = (g_coninf_data.encapsulation == "dslencap_ether" or
g_coninf_data.encapsulation == "dslencap_ipnlpid" or
g_coninf_data.encapsulation == "dslencap_ipsnap" or
g_coninf_data.encapsulation == "dslencap_ipraw")
return result;
end
function is_Dsl_Encaps_Mode2()
result = (g_coninf_data.encapsulation == "dslencap_pppoe" or
g_coninf_data.encapsulation == "dslencap_ether")
return result
end
function Ppp_Led ()
if(g_coninf_data.connection_sperre == "0") then
return "0"
end
if config.LTE then
if (g_coninf_data.lte_state or ""):find('connect_') == 1 then
return "1"
else
return "0"
end
end
if(config.USB_GSM and g_coninf_data.umts_enabled == "1" and g_coninf_data.modem_present=="1") then
if g_coninf_data.connection_status=="5" then
return "1"
end
return "0"
end
if(config.USB_TETHERING and g_coninf_data.tethering_enabled) then
if g_coninf_data.connection_status=="5" then
return "1"
end
return "0"
end
if (general.is_ip_client()) then
if (g_coninf_data.wds_enabled=="1" and g_coninf_data.wds_hop=="1") then
if config.WLAN_WDS2 then
require("net_devices")
local wds_mac_master = box.query("wlan:settings/WDS_mac_master")
local idx, master_dev = net_devices.find_dev_by_mac(g_coninf_data.wlan_list, wds_mac_master)
if (master_dev and master_dev.state=="5") then
return "1"
else
return "0"
end
end
return "1"
end
if(g_coninf_data.connection_status == "5") then
return "1"
else
return "0"
end
end
if ((g_coninf_data.ata_mode ~= "1" and not(is_Dsl_Encaps_Mode1())) or
(g_coninf_data.ata_mode == "1" and g_coninf_data.connection_type == "pppoe" and is_Dsl_Encaps_Mode2())) then
if(g_coninf_data.connection_status == "5") then
return "1"
else
return "0"
end
end
if config.DOCSIS then
if (g_coninf_data.ata_mode == "1" and g_coninf_data.connection_type == "pppoe") then
if(g_coninf_data.connection_status == "5") then
return "1"
else
return "0"
end
end
end
if (g_coninf_data.ata_mode == "1" and g_coninf_data.connection_type == "bridge") then
return "1"
end
if (not(config.LTE) and (g_coninf_data.opmode == "opmode_ether")) or
g_coninf_data.opmode == "opmode_ipnlpid" or
g_coninf_data.opmode == "opmode_ipsnap" or
g_coninf_data.opmode == "opmode_ipraw" then
return g_coninf_data.dsl_carrier_state == "SHOWTIME" and "1" or "0"
end
return "0"
end
function Ppp_Led_Ipv6()
if (g_coninf_data.ipv6_state == "5" and g_coninf_data.connection_sperre == "1") then
return "1"
end
return "0"
end
function State_Led (state)
if (state == "1") then
return "led_green"
end
if (state == "0") then
return "led_gray"
end
return ""
end
local function syslog_link_internet(str)
return '<a href="'..href.get('/system/syslog.lua', 'tab=internet')..'">'..str..'</a>'
end
local function get_akt_provider_name()
if g_coninf_data.akt_provider_id == 'other' then
return box.query("providerlist:settings/activename") or ""
end
if g_coninf_data.provider ~= nil then
for i, v in ipairs(g_coninf_data.provider) do
if v.Id == g_coninf_data.akt_provider_id then
return v.providername
end
end
end
return ""
end
function ip_adr_display()
if (g_coninf_data.pppoe_ip ~= "" and g_coninf_data.pppoe_ip ~= "-" and g_coninf_data.pppoe_ip ~= "0.0.0.0") then
return box.tohtml(g_coninf_data.pppoe_ip)
end
if g_coninf_data.opmode == "opmode_ether" and box.query("box:settings/dslencap_ether/use_dhcp") ~= "1"
or g_coninf_data.opmode == "opmode_ipnlpid"
or g_coninf_data.opmode == "opmode_ipsnap"
or g_coninf_data.opmode == "opmode_ipraw" then
local ip = box.query("box:settings/dslencap_ether/ipaddr")
if ip and ip ~= "" then
return box.tohtml(ip)
end
end
if (g_coninf_data.ata_mode == "1" and g_coninf_data.dhcpclient == "1") then
return box.tohtml(TXT([[{?7172:956?}]]))
end
return ""
end
local function get_ip_addr(ipv6, page)
local str_ip=""
if ipv6 then
if page == "inetmon" then
str_ip = str_ip .. box.tohtml(TXT(
[[{?7172:697?}: ]] .. (g_coninf_data.ipv6_ip or "")
))
end
else
str_ip =str_ip..box.tohtml(TXT([[{?7172:503?}]])).." "..ip_adr_display()
end
return str_ip
end
function Display_Internet(state, ipv6,page)
local str = ""
local oclock = box.tohtml(TXT([[{?7172:785?}]]))
if #oclock > 0 and oclock ~= " " then
oclock = " " .. oclock
elseif oclock==" " then
oclock=""
end
if config.LTE then
local lte_state = g_coninf_data.lte_state or ""
if lte_state == "wait_apn" then
return general.sprintf(box.tohtml(TXT([[{?7172:361?}]])),[[<a href="]]..href.get([[/internet/lte_settings.lua]])..[[">]],[[</a>]])
elseif lte_state == "wait_powercut" then
return box.tohtml(TXT([[{?7172:399?}]]))
end
end
if (general.is_ip_client() and not(ipv6)) then
if (g_coninf_data.wds_enabled=="1" and g_coninf_data.wds_hop=="1") then
if config.WLAN_WDS2 then
if (state=="1") then
local str_ip=get_ip_addr(ipv6, page)
if (str_ip~="") then
str_ip=", "..str_ip
end
return box.tohtml(TXT([[{?7172:434?}]]))..str_ip
else
return box.tohtml(TXT([[{?7172:817?}]]))
end
else
return box.tohtml(TXT([[{?7172:524?}]]))..str_ip
end
end
if (state=="1") then
return box.tohtml(TXT([[{?7172:775?}]]).." "..TXT([[{?7172:728?}]]).. ip_adr_display())
end
return box.tohtml(TXT([[{?7172:781?}]]))
end
local str_connected = box.tohtml(TXT([[{?7172:498?}]])).." "
if ipv6 then
str_connected = str_connected..box.tohtml(g_coninf_data.ipv6_date)
else
str_connected = str_connected..box.tohtml(g_coninf_data.connection_date)
end
str_connected = str_connected..', '
if ipv6 then
str_connected = str_connected..box.tohtml(g_coninf_data.ipv6_time) .. oclock
else
str_connected = str_connected..box.tohtml(g_coninf_data.connection_time) .. oclock
end
if (not ipv6 and g_coninf_data.dslite_active) then
str_connected=box.tohtml(TXT([[{?7172:640?}]])).." "
end
local str_ip=", "
if (page=="inetmon") then
str_ip=",<br>"
end
if ipv6 then
if page == "inetmon" then
str_ip = str_ip .. get_ip_addr(ipv6, page)
local valid, preferred = g_coninf_data.ipv6_ip_valid or "", g_coninf_data.ipv6_ip_preferred or ""
if #valid > 0 and #preferred > 0 then
str_ip = str_ip .. box.tohtml(TXT(
[[, {?7172:222?}: ]] .. valid .. [[/]] .. preferred .. [[s]]
))
end
str_ip = str_ip .. ",<br>"
end
str_ip = str_ip.. box.tohtml(TXT([[{?7172:851?}]]).." "..(g_coninf_data.ipv6_prefix or ""))
if page == "inetmon" then
local valid, preferred = g_coninf_data.ipv6_prefix_valid or "", g_coninf_data.ipv6_prefix_preferred or ""
if #valid > 0 and #preferred > 0 then
str_ip = str_ip .. box.tohtml(TXT(
[[, {?7172:670?}: ]] .. valid .. [[/]] .. preferred .. [[s]]
))
end
end
elseif g_coninf_data.dslite_active then
if (page=="home") then
str_ip = str_ip .. box.tohtml(TXT([[{?7172:371?}]]))
else
local ip6adr=box.query("ipv6:settings/ipv6_active_aftr")
if (ip6adr=="" or ip6adr=="::") then
ip6adr=" --- ";
end
str_ip=box.tohtml(TXT([[{?7172:425?}]])..ip6adr)
end
else
str_ip = str_ip .. get_ip_addr(ipv6, page)
end
if g_coninf_data.umts_enabled == "1" then
if g_coninf_data.connection_status=="5" then
str=str_connected..", "
if g_coninf_data.umts_provider ~= "" then
str = box.tohtml(g_coninf_data.umts_provider..' ')
end
str = str..box.tohtml(TXT([[{?7172:803?}]]))
if umts.InHomeZone == "1" then
str = str .. ", " .. box.tohtml(TXT([[{?7172:486?}]]))
end
local gsm_act = umts.access_technology()
if gsm_act then
str = str .. ", " .. gsm_act
end
if g_coninf_data.expert_mode == "1" then
str=str..str_ip
end
else
str = box.tohtml(TXT([[{?7172:677?}]]))
end
else
if (state == "1") then
str='<span class="limited">'..str_connected..'</span>'
local show_shapedrate = box.query("connection0:settings/shapedrate_in_gui") == "1"
if not(general.is_ip_client()) then
local provider_name = get_akt_provider_name()
if provider_name and #provider_name > 0 then
if g_coninf_data.expert_mode == "1" or show_shapedrate then
str = str..", "..'<span class="limited" style="max-width:240px;">'..box.tohtml(provider_name)..'</span>'
else
str = str..", ".. '<span class="limited" style="max-width:400px;">'..box.tohtml(provider_name)..'</span>'
end
end
end
if show_shapedrate then
local ds = tonumber(box.query("connection0:settings/shapedrate_ds")) or 0
local us = tonumber(box.query("connection0:settings/shapedrate_us")) or 0
ds = math.min(ds, tonumber(g_coninf_data.dsl_down_rate) or 0)
us = math.min(us, tonumber(g_coninf_data.dsl_up_rate) or 0)
local ds_str, us_str = general.build_ds_us_strings(ds, us,
TXT([[{?7172:470?}]]), TXT([[{?7172:565?}]])
)
str = str .. ", "
.. box.tohtml(TXT([[{?7172:63?}]]))
.. [[: ]]
.. box.tohtml(ds_str).."<img src='/css/default/images/dsl_downstream.gif' height='12px'>&nbsp;"
.. box.tohtml(us_str).."<img src='/css/default/images/dsl_upstream.gif' height='12px'>"
end
if g_coninf_data.expert_mode == "1" and (not show_shapedrate or page=="inetmon") then
str=str..'<span class="limited">'..str_ip..'</span>'
end
local is_cable_via_lan=(config.DOCSIS and g_coninf_data.ata_mode == "1" and g_coninf_data.connection_type == "pppoe" and g_coninf_data.connection_status == "5")
if (not(config.LTE) and (g_coninf_data.opmode == "opmode_ether")) or
g_coninf_data.opmode == "opmode_ipnlpid" or
g_coninf_data.opmode == "opmode_ipsnap" or
g_coninf_data.opmode == "opmode_ipraw" or
is_cable_via_lan then
str = box.tohtml(TXT([[{?7172:502?}]]))
if g_coninf_data.expert_mode == "1" then
str = str..str_ip
end
end
else
str = syslog_link_internet(box.tohtml(TXT([[{?7172:668?}]])))
end
end
if g_coninf_data.tethering_enabled then
local tethering_device = TXT([[{?7172:195?}]])
if g_coninf_data.tethering_device ~= "" then
tethering_device = g_coninf_data.tethering_device
end
local change_to_text = box.tohtml(TXT([[{?7172:725?}]]))
change_to_text = change_to_text..[[<a href="]]..href.get("/internet/umts_settings.lua")..[[">]]..box.tohtml(TXT([[{?7172:971?}]]))..[[</a>?]]
if g_coninf_data.connection_status=="5" then
if (g_coninf_data.opmode == "opmode_usb_tethering") then
str = box.tohtml(general.sprintf(TXT([[{?7172:631?}]]), tethering_device..' '))
str = str..[[<a href="]]..href.get("/internet/umts_settings.lua")..[[">(]]..box.tohtml(TXT([[{?7172:210?}]]))..[[)</a>]]
else
str = str..", "..change_to_text
end
else
if (g_coninf_data.opmode == "opmode_usb_tethering") then
str = box.tohtml(general.sprintf(TXT([[{?7172:598?}]]), tethering_device)..", ")
str = str..[[<a href="]]..href.get("/internet/umts_settings.lua")..[[">]]..box.tohtml(TXT([[{?7172:359?}]]))..[[</a>?]]
else
str = syslog_link_internet(box.tohtml(TXT([[{?7172:46?}]])))
str = str..", "..change_to_text
end
end
end
return str
end
g_txt_internet=box.tohtml(TXT([[{?7172:895?}]]))
g_txt_ipv6=box.tohtml(TXT([[{?7172:727?}]]))
g_txt_ipv4=box.tohtml(TXT([[{?7172:783?}]]))
function create_ipv4_row(page)
if page=="home" then
return create_ipv4_row_home()
end
return create_ipv4_row_inetmon()
end
function create_ipv6_row(page)
if page=="home" then
return create_ipv6_row_home()
end
return create_ipv6_row_inetmon()
end
function create_ipv4_row_home()
local led = Ppp_Led()
local txt_ipv4_addon=[[]]
if config.IPV6 and (g_coninf_data.ipv6_enabled == "1") and not general.is_ip_client() then
txt_ipv4_addon=[[, ]]..g_txt_ipv4
end
local str=[[<tr id='uiTrInternet'>]]
str=str..[[<td id='ipv4_led' class=']]..State_Led(led)..[['></td>]]
str=str..[[<td><div id='ipv4_title'><a href=']]..href.get("/internet/inetstat_monitor.lua")..[['>]]..g_txt_internet..txt_ipv4_addon..[[</a></div></td>]]
return str..[[<td><div id='ipv4_info'>]]..Display_Internet(led, false,"home")..[[</div></td></tr>]]
end
function create_ipv6_row_home()
if config.IPV6 and (g_coninf_data.ipv6_enabled == "1") and not general.is_ip_client() then
local led = Ppp_Led_Ipv6()
local str=[[<tr id='uiTrIpv6'>]]
str=str..[[<td id='ipv6_led' class=']]..State_Led(led)..[['></td>]]
str=str..[[<td><div id='ipv6_title'><a href=']]..href.get("/internet/inetstat_monitor.lua")..[['>]]
str = str .. g_txt_internet..[[, ]]..g_txt_ipv6
str = str .. [[</a></div></td>]]
return str..[[<td><div id='ipv6_info'>]]..Display_Internet(led, true,"home")..[[</div></td></tr>]]
end
return ""
end
function create_ipv4_row_inetmon()
local led = Ppp_Led()
local str=[[<tr id='uiTrInternet'>]]
str=str..[[<td><div id='ipv4_title'>]]..g_txt_internet..[[, ]]..g_txt_ipv4..[[</div></td>]]
str=str..[[<td id='ipv4_led'><div class=']]..State_Led(led)..[['>&nbsp;</div></td>]]
return str..[[<td><div id='ipv4_info'>]]..Display_Internet(led, false,"inetmon")..[[</div></td></tr>]]
end
function create_ipv6_row_inetmon()
if config.IPV6 and (g_coninf_data.ipv6_enabled == "1") and not general.is_ip_client() then
local led = Ppp_Led_Ipv6()
local str=[[<tr id='uiTrIpv6'>]]
str=str..[[<td><div id='ipv6_title'>]]..g_txt_internet..[[, ]]..g_txt_ipv6..[[</div></td>]]
str=str..[[<td id='ipv6_led'><div class=']]..State_Led(led)..[['>&nbsp;</div></td>]]
return str..[[<td><div id='ipv6_info'>]]..Display_Internet(led, true,"inetmon")..[[</div></td></tr>]]
end
return ""
end
function create_connection_row(page)
if page=="home" then
return create_connection_row_home()
end
return create_connection_row_inetmon()
end
function get_connection_rowinfo()
local Displaytxt=""
local Led="0"
local Majortxt=""
local bWarn=false
local kbit_str = TXT([[{?7172:104?}]])
local mbit_str = TXT([[{?7172:435?}]])
local MajorLink= href.get("/internet/dsl_overview.lua")
if config.LTE then
require"lted"
MajorLink=href.get("/internet/lte_overview.lua")
Majortxt= box.tohtml(TXT([[{?7172:237?}]]))
local lte_state = g_coninf_data.lte_state or ""
Displaytxt = box.tohtml(TXT([[{?7172:193?}]]))
if lte_state == "search" or lte_state == "reestablish" then
Displaytxt = box.tohtml(TXT([[{?7172:821?}]]))
elseif lte_state == "wait_sim" then
Displaytxt = box.tohtml(TXT([[{?7172:704?}]]))
elseif lte_state == "wait_apn" then
-- nicht verbunden anzeigen
elseif lte_state == "wait_powercut" then
-- nicht verbunden anzeigen
elseif lted.waiting_for('pin', 'puk') then
MajorLink=href.get("/internet/lte_settings.lua")
Displaytxt = box.tohtml(TXT([[{?7172:149?}]]))
bWarn = true
elseif lte_state:find("connect_") == 1 then
Displaytxt = box.tohtml(TXT([[{?7172:763?}]]))
Led = "1"
local ds = tonumber(g_coninf_data.lte_connrate_rx) or 0
local us = tonumber(g_coninf_data.lte_connrate_tx) or 0
if ds > 0 and us > 0 then
local ds_str, us_str = general.build_ds_us_strings(ds, us, kbit_str, mbit_str)
local Additionaltxt = ", "..box.tohtml(ds_str).."<img src='/css/default/images/dsl_downstream.gif' height='12px'>&nbsp;"..box.tohtml(us_str).."<img src='/css/default/images/dsl_upstream.gif' height='12px'>"
Displaytxt = Displaytxt .. Additionaltxt
end
end
elseif config.DOCSIS then
Majortxt= box.tohtml(TXT([[{?7172:951?}]]))
MajorLink=href.get("/internet/docsis_overview.lua")
if config.USB_GSM and g_coninf_data.umts_enabled == "1" and g_coninf_data.gsm_established == "1" then
Displaytxt=box.tohtml(TXT([[{?7172:198?}]]))
MajorLink = ""
elseif g_coninf_data.opmode ~= 'opmode_standard' then
Displaytxt=box.tohtml(TXT([[{?7172:544?}]]))
MajorLink = ""
else
Displaytxt=box.tohtml(TXT([[{?7172:317?}]]))
if (g_coninf_data.initStage>=16) then
Led="1"
Displaytxt=box.tohtml(TXT([[{?7172:3684?}]]))
local ds, us = g_coninf_data.dsMaxTrafficRate, g_coninf_data.usMaxTrafficRate
if ds > 0 and us > 0 then
require"docsis"
local ds_str, us_str = docsis.traffic_display(ds), docsis.traffic_display(us)
local Additionaltxt = ", "..box.tohtml(ds_str).."<img src='/css/default/images/dsl_downstream.gif' height='12px'>&nbsp;"..box.tohtml(us_str).."<img src='/css/default/images/dsl_upstream.gif' height='12px'>"
Displaytxt = Displaytxt .. Additionaltxt
end
end
end
else
if config.DSL or config.VDSL then
Majortxt="DSL"
else
Majortxt="ATA"
end
Displaytxt=box.tohtml(TXT([[{?7172:626?}]]))
if not (config.USB_GSM and (g_coninf_data.umts_enabled == "1" or g_coninf_data.opmode == "opmode_usb_modem")) then
bWarn=(g_coninf_data.hint_dsl_no_cable == "1")
if (g_coninf_data.ata_mode == "1") then
MajorLink=href.get("/internet/internet_settings.lua","activtype="..box.tohtml(tostring(g_coninf_data.connection_type)))
else
Displaytxt = box.tohtml(TXT([[{?7172:753?}]]))
if g_coninf_data.dsl_diag_active == "1" then
Displaytxt = box.tohtml(TXT([[{?7172:117?}]]))
end
local Additionaltxt = [[: <a href="]]..href.get("/system/syslog.lua")..[[">]]..box.tohtml(TXT([[{?7172:411?}]]))..[[</a>]]
if (g_coninf_data.dsl_carrier_state == "HS" or g_coninf_data.dsl_carrier_state == "RTDL") then
Displaytxt = box.tohtml(TXT([[{?7172:9840?}]]))
Additionaltxt = ""
end
if (g_coninf_data.dsl_carrier_state == "SHOWTIME") then
if (not general.is_ip_client()) then
Led="1"
end
Displaytxt = box.tohtml(TXT([[{?7172:914?}]]))
local ds = tonumber(g_coninf_data.dsl_down_rate) or 0
local us = tonumber(g_coninf_data.dsl_up_rate) or 0
local ds_str, us_str = general.build_ds_us_strings(ds, us, kbit_str, mbit_str)
Additionaltxt = ", "..box.tohtml(ds_str).."<img src='/css/default/images/dsl_downstream.gif' height='12px'>&nbsp;"..box.tohtml(us_str).."<img src='/css/default/images/dsl_upstream.gif' height='12px'>"
end
if g_coninf_data.dsl_diag_active == "1" then
local Diagtxt = '<a href="'..href.get("/dsldiagstop.lua")..'">'..box.tohtml(TXT([[{?7172:759?}]]))..'</a>'
if config.LABOR_DSL then
Diagtxt = box.tohtml(TXT([[{?7172:518?}]]))
end
if box.query("logic:status/uptime_hours")=="0" then
local min = tonumber(box.query("logic:status/uptime_minutes"))
if min <= 15 then
Diagtxt = box.tohtml(general.sprintf(TXT([[{?7172:736?}]]), min))
end
end
Displaytxt = Displaytxt .. ", " .. Diagtxt
else
Displaytxt = Displaytxt .. Additionaltxt
end
end
end
end
return box.tohtml(Majortxt),MajorLink,Led,Displaytxt,bWarn
end
function create_connection_row_home()
local Majortxt,MajorLink,Led,Displaytxt,bWarn=get_connection_rowinfo()
local str=""
str=str..[[<tr id="uiTrDsl">]]
str=str..[[<td class="]]..State_Led(Led)..[["></td>]]
if MajorLink ~= "" then
str=str..[[<td ><a href="]]..MajorLink..[[">]].. Majortxt.. [[</a></td>]]
else
str=str..[[<td>]].. Majortxt.. [[</td>]]
end
str=str..[[<td ]]
if (bWarn) then
str=str..[[class="WarnMsg"]]
end
str=str..[[>]]..Displaytxt..[[</td>]]
str=str..[[</tr>]]
return str
end
function create_connection_row_inetmon()
local Majortxt,MajorLink,Led,Displaytxt,bWarn=get_connection_rowinfo()
local str=""
str=str..[[<tr id="uiTrDsl">]]
if MajorLink ~= "" then
str=str..[[<td ><a href="]]..MajorLink..[[">]].. Majortxt.. [[</a></td>]]
else
str=str..[[<td>]].. Majortxt.. [[</td>]]
end
str=str..[[<td><div class="]]..State_Led(Led)..[[">&nbsp;</div></td>]]
str=str..[[<td ]]
if (bWarn) then
str=str..[[class="WarnMsg"]]
end
str=str..[[>]]..Displaytxt..[[</td>]]
str=str..[[</tr>]]
return str
end
function get_conn_inf_part()
local conninf = {}
conninf.connection_sperre = box.query("connection0:settings/enabled")
conninf.umts_enabled = box.query("umts:settings/enabled")
conninf.modem_present = box.query("gsm:settings/ModemPresent")
conninf.gsm_established = "0"
if (conninf.modem_present == "1") then
conninf.gsm_established = box.query("gsm:settings/Established")
end
conninf.connection_status = box.query("connection0:status/connect")
conninf.tethering_device = box.query("ctlusb:settings/tethering_device")
conninf.tethering_enabled = conninf.tethering_device ~= ""
conninf.ap_enabled = box.query("wlan:settings/ap_enabled")
conninf.ap_enabled_scnd = box.query("wlan:settings/ap_enabled_scnd")
conninf.wds_enabled = box.query("wlan:settings/WDS_enabled")
conninf.wds_hop = box.query("wlan:settings/WDS_hop")
conninf.wlan_list = general.listquery("wlan:settings/wlanlist/list(state,is_guest,mac)")
conninf.ata_mode = box.query("box:settings/ata_mode")
conninf.encapsulation = box.query("sar:settings/encapsulation")
conninf.connection_type = box.query("connection0:settings/type")
conninf.opmode = box.query("box:settings/opmode")
conninf.pppoe_ip = box.query("connection0:status/ip")
conninf.dhcpclient = box.query("interfaces:settings/lan0/dhcpclient")
conninf.connection_date = box.query("connection0:status/conntime_date")
conninf.connection_time = box.query("connection0:status/conntime_time")
conninf.umts_provider = box.query("umts:settings/name")
conninf.expert_mode = box.query("box:settings/expertmode/activated")
conninf.dslite_active = false
conninf.ipv6_enabled = box.query("ipv6:settings/enabled")
if (conninf.ipv6_enabled=="1") then
conninf.dslite_active = box.query("ipv6:settings/ipv4_active_mode") ~= "ipv4_normal"
conninf.ipv6_state = box.query("ipv6:settings/state")
conninf.ipv6_prefix = box.query("ipv6:settings/prefix")
conninf.ipv6_date = box.query("ipv6:status/conntime_date")
conninf.ipv6_time = box.query("ipv6:status/conntime_time")
conninf.ipv6_ip = box.query("ipv6:settings/ip")
conninf.ipv6_ip_valid = box.query("ipv6:settings/ip_valid")
conninf.ipv6_ip_preferred = box.query("ipv6:settings/ip_preferred")
conninf.ipv6_prefix_valid = box.query("ipv6:settings/prefix_valid")
conninf.ipv6_prefix_preferred = box.query("ipv6:settings/prefix_preferred")
end
require("libluadsl")
conninf.dsl_up_rate = luadsl.getOverviewStatus(1,"DS").ACT_DATA_RATE_US or 0
conninf.dsl_down_rate = luadsl.getOverviewStatus(1,"DS").ACT_DATA_RATE_DS or 0
if config.LTE then
conninf.lte_state = box.query("lted:settings/hw_info/ue/connection/state")
conninf.lte_connrate_tx = box.query("lted:settings/hw_info/ue/connection/connrate_tx")
conninf.lte_connrate_rx = box.query("lted:settings/hw_info/ue/connection/connrate_rx")
end
conninf.akt_provider_id= box.query("providerlist:settings/activeprovider")
conninf.provider= general.listquery("providerlist:settings/providerlist/list(providername,Id)")
conninf.dsl_carrier_state = general.get_dsl_state()
return conninf
end
