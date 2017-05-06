<?lua
g_page_type = "all"
g_page_title = [[]]
dofile("../templates/global_lua.lua")
if box.get.log ~= "1" and log then
log.disable()
end
require("general")
require("bit")
conv = require("convert_file_size")
require("first")
require("usb_devices")
any_usb_host= config.USB_HOST or config.USB_HOST_AVM or config.USB_HOST_TI
require("webdav")
require("store")
require("string_op")
require("fon_numbers")
require("umts")
require("connection")
require("http")
g_coninf_data={}
g_ajax = false
if box.get.useajax then
g_ajax = true
end
if box.post.useajax then
g_ajax = true
end
g_countKomfort=0
g_MaxKomfort=5
g_MaxBlockInfo=8
g_show_full_comfort = true
g_no_comfort_link = true
if (g_show_full_comfort) then
g_MaxKomfort=100
end
local RefreshDiversity=0
if (box.get.query==nil) then
RefreshDiversity= box.query("telcfg:settings/RefreshDiversity")
g_coninf_data = connection.get_conn_inf_part()
g_coninf_data.ddns_activated= box.query("ddns:settings/account0/activated")
if (g_coninf_data.ddns_activated=="1") then
g_coninf_data.ddns_password= box.query("ddns:settings/account0/password")
g_coninf_data.ddns_username= box.query("ddns:settings/account0/username")
g_coninf_data.ddns_provider= box.query("ddns:settings/account0/ddnsprovider")
g_coninf_data.ddns_domain= box.query("ddns:settings/account0/domain")
g_coninf_data.ddns_state= box.query("ddns:settings/account0/state")
end
g_coninf_data.usb_carrier= box.query("usb:status/carrier")
g_coninf_data.webdav_enabled= box.query("webdavclient:settings/enabled")
if (g_coninf_data.webdav_enabled=="1") then
g_coninf_data.mountpoint= box.query("webdavclient:settings/mountpoint")
g_coninf_data.sum_failed_uploads= box.query("webdavclient:settings/sum_failed_uploads")
g_coninf_data.connection_state= box.query("webdavclient:status/connection_state")
g_coninf_data.dirty_files= box.query("webdavclient:status/dirty_files")
g_coninf_data.failed_uploads= box.query("webdavclient:status/failed_uploads")
g_coninf_data.finished_uploads= box.query("webdavclient:status/finished_uploads")
g_coninf_data.storage_quota_avail= box.query("webdavclient:status/storage_quota_avail")
g_coninf_data.storage_quota_used= box.query("webdavclient:status/storage_quota_used")
g_coninf_data.traffic_quota_avail= box.query("webdavclient:status/traffic_quota_avail")
g_coninf_data.traffic_quota_used= box.query("webdavclient:status/traffic_quota_used")
end
g_coninf_data.wlan_config_status= box.query("wlan:settings/wlan_config_status")
g_coninf_data.ap_enabled= box.query("wlan:settings/ap_enabled")
g_coninf_data.ap_enabled_scnd= box.query("wlan:settings/ap_enabled_scnd")
if (g_coninf_data.ap_enabled=="1" or g_coninf_data.ap_enabled_scnd=="1") then
g_coninf_data.wlanguest_active= box.query("wlan:settings/guest_ap_enabled")
g_coninf_data.wlanguest_encryt= box.query("wlan:settings/guest_encryption")
g_coninf_data.wlanguest_time_remain=box.query("wlan:settings/guest_time_remain")
g_coninf_data.encryption= box.query("wlan:settings/encryption")
g_coninf_data.bg_mode= box.query("wlan:settings/bg_mode")
require("net_devices")
g_coninf_data.wlan_list=net_devices.g_WlanList
g_coninf_data.lan_list=net_devices.g_list
end
g_coninf_data.eth0= box.query("eth0:status/carrier")
g_coninf_data.eth1= box.query("eth1:status/carrier")
g_coninf_data.eth2= box.query("eth2:status/carrier")
g_coninf_data.eth3= box.query("eth3:status/carrier")
g_coninf_data.dsl_carrier_state = general.get_dsl_state()
g_coninf_data.hint_dsl_no_cable= box.query("box:status/hint_dsl_no_cable")
g_coninf_data.dsl_diag_active = box.query("sar:settings/DslDiagnosticStart")
g_coninf_data.dect_enabled= box.query("dect:settings/enabled")
g_coninf_data.dect_repeater_enabled= box.query("dect:settings/DECTRepeaterEnabled")
if (g_coninf_data.dect_enabled=="1") then
g_coninf_data.dect_device_list= general.listquery("dect:settings/Handset/list(Subscribed)")
end
g_coninf_data.connection_voip= box.query("connection0:status/voipconnect")
g_coninf_data.boxDate= box.query("box:status/localtime")
g_coninf_data.FirmwareSigned = box.query("box:status/signed_firmware")
g_coninf_data.ShowDefaults = box.query("box:status/provider_default_config")
g_coninf_data.morphstick_enabled = box.query("morphstick:settings/enabled")
g_coninf_data.isLabor = false
g_coninf_data.ipv6firewall_rules = {}
if (g_coninf_data.ipv6_enabled=="1") then
g_coninf_data.ipv6firewall_rules = general.listquery("ipv6firewall:settings/rule/list(enabled)")
end
g_coninf_data.forwardrules = general.listquery ("forwardrules:settings/rule/list(activated,protocol,port,endport)")
g_coninf_data.use_exposed_host = box.query("forwardrules:settings/use_exposed_host")
g_coninf_data.exposed_host = box.query("forwardrules:settings/exposed_host")
g_coninf_data.upnp_activated = box.query("box:settings/upnp/activated")
g_coninf_data.upnp_control_activated = box.query("box:settings/upnp/control_activated")
g_coninf_data.igdforwardrules = general.listquery("igdforwardrules:settings/rule/list(protocol,port)")
g_coninf_data.CallerIdActions = general.listquery("telcfg:settings/CallerIDActions/list(Action,Active,Destination)")
g_coninf_data.DiversityList = general.listquery("telcfg:settings/Diversity/list(Active,Destination)")
g_coninf_data.CallerIdRoutes = general.listquery("telcfg:settings/Routing/Group/list(Route)")
g_coninf_data.callthroughActive = box.query("telcfg:settings/CallThrough/Active")
g_coninf_data.intFaxActive = config.FAX2MAIL and (box.query("telcfg:settings/FaxMailActive")~="")
g_coninf_data.isUpdateAvail = box.query("updatecheck:status/update_available_hint")
g_coninf_data.NightlockEnabled = box.query("box:settings/night_time_control_enabled")
g_coninf_data.WlanNightlockEnabled = "0"
if config.WLAN then
g_coninf_data.WlanNightlockEnabled = box.query("wlan:settings/night_time_control_enabled")
end
if (g_coninf_data.NightlockEnabled=="1" or g_coninf_data.WlanNightlockEnabled=="1") then
g_coninf_data.NightlockOfftime = box.query("box:settings/night_time_control_off_time")
g_coninf_data.NightlockOntime = box.query("box:settings/night_time_control_on_time")
end
if config.TIMERCONTROL and config.WLAN then
require("timer")
timer.read_wlan("home_startpage")
if (timer.active("home_startpage")) then
g_coninf_data.WlanNightlockEnabled = "1"
g_coninf_data.WlanNightlockTimeplan = true
if timer.daily_mode("home_startpage") then
g_coninf_data.WlanNightlockTimeplan = false
g_coninf_data.WlanNightlockOfftime = string.gsub(timer.daily_end("home_startpage"), "(%d%d)(%d%d)", function(hour, minute) return hour..":"..minute end)
g_coninf_data.WlanNightlockOntime = string.gsub(timer.daily_start("home_startpage"), "(%d%d)(%d%d)", function(hour, minute) return hour..":"..minute end)
end
else
g_coninf_data.WlanNightlockEnabled = "0"
end
end
g_coninf_data.Fonlist = nil
g_coninf_data.msn = {}
g_coninf_data.msn_count = 0
if config.FON then
g_coninf_data.Alarmclock1Active = box.query("telcfg:settings/AlarmClock0/Active")
g_coninf_data.Alarmclock2Active = box.query("telcfg:settings/AlarmClock1/Active")
g_coninf_data.Alarmclock3Active = box.query("telcfg:settings/AlarmClock2/Active")
if store.internal_memory_available() then
g_coninf_data.InternalMemUsedSpace = box.query("usbdevices:settings/internalflash/usedspace")
g_coninf_data.InternalMemCapacity = box.query("usbdevices:settings/internalflash/capacity")
end
g_coninf_data.sipEntries = general.listquery("sip:settings/sip/list(activated,displayname)")
g_coninf_data.sipEntriesState = general.listquery("sip:status/sip/list(connect)")
local msn_list = general.listquery("telcfg:settings/MSN/MSN/list()")
local tmp = ""
if msn_list then
for i,v in ipairs(msn_list) do
for j,k in ipairs(v) do
tmp = box.query("telcfg:settings/MSN/"..k)
if tmp ~= nil and tmp ~= "" then
g_coninf_data.msn_count = g_coninf_data.msn_count + 1
g_coninf_data.msn[g_coninf_data.msn_count] = tmp
end
end
end
end
g_coninf_data.pots = box.query("telcfg:settings/MSN/POTS")
g_coninf_data.mobile_msn = box.query("telcfg:settings/Mobile/MSN")
g_coninf_data.use_PSTN = box.query("telcfg:settings/UsePSTN")
g_coninf_data.TamNumNewMsg=box.query("tam:settings/NumNewMessages")
g_coninf_data.TamFailReason=box.query("tam:settings/LoadFailReason")
g_coninf_data.Tam={}
for i=0,4,1 do
local val={}
val.active =box.query("tam:settings/TAM"..i.."/Active")
val.display =box.query("tam:settings/TAM"..i.."/Display")
val.NewMsg =box.query("tam:settings/TAM"..i.."/NumNewMessages")
val.NumOldMsg=box.query("tam:settings/TAM"..i.."/NumOldMessages")
table.insert(g_coninf_data.Tam,val);
end
g_coninf_data.UseClickToDial=box.query("telcfg:settings/UseClickToDial")
g_coninf_data.right_to_dial = tonumber(box.query("rights:status/Dial",0)) > 0
end
if config.DOCSIS then
g_coninf_data.initStage = tonumber(box.query("docsis:status/DocsisDbEntry/initStage")) or 0
if g_coninf_data.initStage>=16 then
g_coninf_data.dsMaxTrafficRate = tonumber(box.query("docsis:status/QosMainDb/dsMaxTrafficRate")) or 0
g_coninf_data.usMaxTrafficRate = tonumber(box.query("docsis:status/QosMainDb/usMaxTrafficRate")) or 0
end
end
end
g_Productname = config.PRODUKT_NAME
g_Firmware_Version = {[[{?537:628?}]]}
local nspver = box.query("logic:status/nspver")
nspver = nspver:gsub("^(.-%.)", "")
if config.LABOR_ID_NAME and config.LABOR_ID_NAME ~= "" then
nspver = nspver.." "..config.LABOR_ID_NAME
end
table.insert(g_Firmware_Version, nspver)
function TdPasswortInfo(colspan)
local str = [[<td class="td_right"]]
if (colspan) then
str = str..[[ colspan="2"]]
end
str = str ..[[>]]..general.pwd_info()..[[</td>]]
return str
end
function TdLaborInfo(colspan2)
local str = "<td "
if (colspan2) then
str = str..[[colspan="2" ]]
end
local link = ""
local href = [[http://www.avm.de/labor]]
if config.language ~= 'de' then
href = [[http://www.avm.de/en/lab]]
end
if config.LABOR_ID_NAME and config.LABOR_ID_NAME ~= "" then
link = [[: <a href="]]..href..[[" target="_blank">]]..box.tohtml([[{?537:397?}]])..[[</a>]]
end
str = str..[[class="td_right">]]..box.tohtml([[{?537:731?}]])..link..[[</td>]]
return str
end
function TdUpdateInfo(colspan2)
local str = "<td "
if (colspan2) then
str = str..[[colspan="2" ]]
end
str = str..[[class="td_right">]]..general.fritz_os_update()..[[</td>]]
return str
end
function tr_produkt_info()
local str = ""
local pwInfo = not(gl.logged_in and gl.show_logout)
local laborInfo = g_coninf_data.isLabor
local updateInfo = (g_coninf_data.isUpdateAvail == "1")
str= str..[[<tr>]]
str= str..[[<td><a href="]]..href.get("/system/energy.lua")..[[">]]
str= str..box.tohtml([[{?537:120?}: ]]..box.query("power:status/rate_sumact"))..[[%</a></td>]]
if (pwInfo or laborInfo or updateInfo) then
local colspan2 = true;
if (pwInfo) then
if (laborInfo==false and updateInfo==false) then
str = str..TdPasswortInfo(true)
else
str = str..TdPasswortInfo(false)
end
colspan2 = false;
end
if (laborInfo) then
colspan2=false
if (pwInfo) then
str = str.."</tr><tr>"
colspan2=true
end
str = str..TdLaborInfo(colspan2)
if (updateInfo) then
str = str.."</tr><tr>"
str = str..TdUpdateInfo(true)
end
else
if (updateInfo) then
if (pwInfo) then
str = str.."</tr><tr>"
colspan2=true;
end
str = str..TdUpdateInfo(colspan2)
end
end
else
str=str.."<td>&nbsp;</td>"
end
str = str.."</tr>"
return str
end
function tr_not_signed()
if (g_coninf_data.FirmwareSigned=="1") then
return ""
end
local str=[[<tr><td colspan="2" class="td_right">]]
str=str..box.tohtml([[{?537:965?}]])..":&nbsp;"
str=str..[[<a href="javascript:help.popup(']]..href.help_get("hilfe_nichtsigniert.html","hide=yes")..[[');">]]
str=str..box.tohtml([[{?537:594?}]])..[[.</a>]]
str=str.."</td></tr>"
return str
end
function tr_provider_defaults()
if (g_coninf_data.ShowDefaults ~="11") then
return ""
end
local str=[[<tr><td colspan="2" class="td_right">]]
str=str..box.tohtml([[{?537:430?}]])..":&nbsp;"
str=str..[[<a href="javascript:jslPopHelp('hilfe_ProviderDefaults')">]]
str=str..box.tohtml([[{?537:288?}]])..[[.</a>]]
str=str.."</td></tr>"
return str
end
function State_Led(state)
if (state == "1") then
return "led_green"
end
if (state == "0") then
return "led_gray"
end
return ""
end
function rep_is_connected(suffix)
if not suffix then
suffix = ""
end
local staMac = box.query("wlan:settings/STA_mac_master"..suffix)
if (staMac == "" or staMac == "00:00:00:00:00:00") then
return false, nil
end
local res=false
require("net_devices")
local wlanList= net_devices.g_WlanList
local idx,elem=net_devices.find_dev_by_mac(wlanList,staMac)
local hostname=""
if (elem and elem.is_ap=="1") then
hostname=elem.hostname
res=(elem.ap_state=="5")
end
return res, hostname
end
function tr_connect_info_plc()
local str=""
return str
end
function tr_repeater_cable()
local dvb_streams = luadvb.getActiveStreams()
local led="0"
local Displaytxt = box.tohtml([[{?537:619?}]])
if dvb_streams.no_active_streams > 0 then
Displaytxt = box.tohtml([[{?537:7351?}]])
led = "1"
end
local str = [[
<tr>
<td class=']]..State_Led(led)..[['></td>]]
str=str..[[<td><div><a href="]]..href.get("/dvb/settings.lua")..[[">]]..box.tohtml([[{?537:111?}]])..[[</a></div></td>]]
str=str..[[<td><div>]]..Displaytxt..[[</div></td></tr>]]
return str
end
function tr_repeater_wlan_uplink(band)
led="0"
local ap_band_txt = ""
local suffix = ""
if band == "5" then
ap_band_txt = " (5 GHz)"
suffix = "_scnd"
elseif band == "24" then
ap_band_txt = " (2,4 GHz)"
end
local connected,hostname=rep_is_connected(suffix)
if (connected) then
led="1"
if (hostname=="" or hostname=="-") then
hostname=box.query("wlan:settings/STA_ssid"..suffix)
end
Displaytxt = box.tohtml([[{?537:55?}: ]]..hostname..ap_band_txt)
else
local base_name=box.query("wlan:settings/STA_ssid"..suffix)
if (base_name=="") then
base_name=[[{?537:331?}]]
end
Displaytxt=box.tohtml([[{?537:805?}: ]]..base_name..ap_band_txt)
end
Displaytxt=Displaytxt..box.tohtml([[, {?537:679?} ]])
if general.has_lanport() then
Displaytxt=Displaytxt..[[<a href="]]..href.get("/system/rep_mode.lua")..[[">]]
end
Displaytxt=Displaytxt..box.tohtml([[{?537:375?}]])
if general.has_lanport() then
Displaytxt=Displaytxt..[[</a>]]
end
local str = [[
<tr id='uiTrWlanBasis]]..suffix..[['>
<td id='wlanbase_led]]..suffix..[[' class=']]..State_Led(led)..[['></td>]]
str=str..[[<td><div id="wlanbase_title]]..suffix..[[">]]..box.tohtml([[{?537:778?}]])..[[</div></td>]]
str=str..[[<td><div id='wlanbase_info]]..suffix..[['>]]..Displaytxt..[[</div></td></tr>]]
return str
end
function tr_RepeaterWlan()
local str=""
return str
end
function tr_internet()
return connection.create_ipv4_row("home")
end
function tr_internet_Ipv6()
return connection.create_ipv6_row("home")
end
function check_number_not_included(numbers, number)
for i,v in ipairs(numbers) do
if v == number then
return false
end
end
return true
end
function syslog_link(str)
return '<a href="'..href.get('/system/syslog.lua', 'tab=telefon')..'">'..str..'</a>'
end
function tr_internet_Sips()
local str="<tr id='uiTrSips'>"
local led="0"
local status=""
if not(config.FON) then
return ""
end
local num_tab = fon_numbers.get_all_numbers()
local active_registered_numbers = fon_numbers.get_active_registered_numbers(num_tab)
local active_not_registered_numbers = fon_numbers.get_active_not_registered_numbers(num_tab)
active_registered_numbers = array.unique(active_registered_numbers)
local diff = num_tab.activ_registered_count - #active_registered_numbers
if diff > 0 then
num_tab.activ_count = num_tab.activ_count - diff
end
table.sort(active_registered_numbers)
table.sort(active_not_registered_numbers)
if num_tab.number_count <= 0 then
led="0"
status = box.tohtml(general.sprintf([[{?537:146?}]], general.Callnumber_string(0)))
elseif num_tab.activ_count == 0 and num_tab.number_count > 0 then
led="0"
status = box.tohtml(general.sprintf([[{?537:838?}]], general.Callnumber_string(0)))
elseif num_tab.activ_count <= 3 and num_tab.activ_not_registered_count == 0 then
led="1"
status = box.tohtml(general.sprintf([[{?537:179?} ]], (num_tab.activ_count - num_tab.activ_not_registered_count), general.Callnumber_string(num_tab.activ_count - num_tab.activ_not_registered_count)))
status = status..box.tohtml(table.concat(active_registered_numbers, ", "))
elseif num_tab.activ_count > 3 and num_tab.activ_not_registered_count == 0 then
led="1"
status = box.tohtml(general.sprintf([[{?537:451?}]], num_tab.activ_count, general.Callnumber_string(num_tab.activ_count)))
elseif num_tab.activ_count == num_tab.activ_not_registered_count then
led="0"
status = general.sprintf([[{?537:471?}]], box.tohtml(num_tab.activ_count), box.tohtml(general.Callnumber_string(num_tab.activ_count)), syslog_link(box.tohtml([[{?537:529?}]])))
else
led="1"
status = general.sprintf([[{?537:4648?}]], box.tohtml(num_tab.activ_count), box.tohtml(general.Callnumber_string(num_tab.activ_count)), syslog_link(box.tohtml(tostring(num_tab.activ_not_registered_count))))
if num_tab.activ_not_registered_count <= 2 then
status = status..': '
status = status..box.tohtml(table.concat(active_not_registered_numbers, ", "))
end
end
if ((general.is_atamode(g_coninf_data) or g_coninf_data.connection_type=="pppoe") and (num_tab.activ_registered_count==0)) or
((config.USB_GSM and g_coninf_data.umts_enabled == "1") and (g_coninf_data.gsm_established == "0")) then
led="0"
end
if umts.is_voice_modem() then
led="1"
end
if (fon_numbers.is_fixed_line_only()) then
if (fon_numbers.is_fixed_line_avail()) then
led="1"
else
led="0"
end
end
str=str.."<td class='"..State_Led(led).."'></td>"
str=str.."<td><a href='"..href.get("/fon_num/fon_num_list.lua").."'>"..box.tohtml([[{?537:794?}]])..[[</a></td>]]
str=str.."<td>"..status.."</td>"
return str
end
function ewe_meter_led()
local meter_ip = box.query("ewe:settings/MeterIP")
if array.all({"", "er", "no-emu"}, func.neq(meter_ip)) then
require("net_devices")
return net_devices.is_active("ip", meter_ip) and "1" or "0"
end
return "0"
end
function Dsl_Led()
local Led="0"
if (g_coninf_data.ata_mode == "1") then
if (g_coninf_data.eth0 == "1") then
Led="1"
end
else
if (g_coninf_data.dsl_carrier_state == "SHOWTIME") then
if (not general.is_ip_client()) then
Led="1"
end
end
end
return Led
end
function tr_connect_info_dsl()
return connection.create_connection_row("home")
end
function tr_connect_info_dect()
if not(config.DECT2) then
return ""
end
local str=""
local Led="0"
local Displaytxt=[[{?537:338?}]]
local MajorLink=href.get("/dect/dect_settings.lua")
if (g_coninf_data.dect_enabled=="1") then
Led="1"
Displaytxt=general.get_dect_info(g_coninf_data)
end
str=str..[[<tr id="uiTrDect">]]
str=str..[[<td class="]]..State_Led(Led)..[["></td>]]
str=str..[[<td><a href="]]..MajorLink..[[">DECT</a></td>]]
str=str..[[<td>]]..box.tohtml(Displaytxt)..[[</td>]]
str=str..[[</tr>]]
return str
end
function get_wlan_clients(guest_only)
local countWlan=0
if (g_coninf_data.lan_list~=nil) then
for i, elem in ipairs(g_coninf_data.lan_list) do
if elem.wlan == "1" and ((guest_only and elem.guest == "1" and elem.active=="1" and elem.wlan_show_in_monitor=="1") or (not(guest_only) and elem.active=="1")) then
countWlan=countWlan+1
end
end
end
return countWlan
end
function get_smarthome_timer_rul(is_auto,timer_type,standby)
if not is_auto and not standby then
return [[{?537:888?}]]
end
local timer_types={
{id="daily", name="{?537:711?}"},
{id="weekly", name="{?537:290?}"},
{id="zufall", name="{?537:8911?}"},
{id="rythmisch", name="{?537:133?}"},
{id="single", name="{?537:323?}"},
{id="sun_calendar", name="{?537:9125?}"},
{id="moon_calendar", name="{?537:6820?}"},
{id="calendar", name="{?537:870?}"}
}
for i,elem in ipairs(timer_types) do
if (elem.id==timer_type) then
return elem.name
end
end
return [[{?537:416?}]]
end
function get_local_aha(aha_list)
for i,elem in ipairs(aha_list) do
if elem.ID>=1000 and elem.ID<=1400 then
return elem
end
end
return aha_list[1]
end
function tr_connect_info_smarthome()
local str=[[]]
return str
end
function tr_connect_info_wlan(band)
if not(config.WLAN) then
return ""
end
local str=""
local Displaytxt=[[{?537:255?}]]
local Led="0"
local MajorLink=href.get("/wlan/wlan_settings.lua")
local wlan_Enabled=(g_coninf_data.ap_enabled == "1" or g_coninf_data.ap_enabled_scnd == "1") and g_coninf_data.wlan_config_status ~= "fail"
if (wlan_Enabled) then
Led="1"
Displaytxt =[[{?537:584?}]]
end
local ssid = ""
if g_coninf_data.ap_enabled == "0" and g_coninf_data.ap_enabled_scnd == "1" then
ssid = box.query("wlan:settings/ssid_scnd")
else
ssid = box.query("wlan:settings/ssid")
end
local ap_band_txt = ""
if band == "5" then
ssid = box.query("wlan:settings/ssid_scnd")
ap_band_txt = " 5 GHz"
elseif band == "24" then
ssid = box.query("wlan:settings/ssid")
ap_band_txt = " 2,4 GHz"
end
local tooltip=Displaytxt
local txt = [[{?537:17?}]]
if not config.GUI_IS_REPEATER or config.GUI_IS_REPEATER and g_rep_mode=="lan_bridge" then
Displaytxt = Displaytxt..", "..general.sprintf(txt, ssid, ap_band_txt)
if config.WLAN.is_double_wlan then
tooltip = tooltip..", "..general.sprintf(txt, box.query("wlan:settings/ssid"), " (2,4 GHz)")
tooltip = tooltip..", "..general.sprintf(txt, box.query("wlan:settings/ssid_scnd"), " (5 GHz)")
end
end
str=str..[[<tr id="uiTrWlan">]]
str=str..[[<td class="]]..State_Led(Led)..[["></td>]]
str=str..[[<td><a href="]]..MajorLink..[[">WLAN]]..ap_band_txt..[[</a></td>]]
str=str..add_td_with_tooltip(Displaytxt, tooltip)
str=str.."</tr>"
return str
end
function tr_connect_info_dvb()
local dvb_connection = luadvb.getConnection()
local led="0"
local Displaytxt = box.tohtml([[{?537:2977?}]])
if dvb_connection.connected then
Displaytxt = box.tohtml([[{?537:3685?}]])
led = "1"
end
local str = [[
<tr>
<td class=']]..State_Led(led)..[['></td>]]
str=str..[[<td><div><a href="]]..href.get("/dvb/usage.lua")..[[">]]..box.tohtml([[{?537:306?}]])..[[</a></div></td>]]
str=str..[[<td><div>]]..Displaytxt..[[</div></td></tr>]]
return str
end
function tr_connect_info_lan()
local str=""
local Displaytxt=""
local Led="0"
local MajorLink=href.get("/net/network_user_devices.lua")
if(g_coninf_data.eth0 == "1" or g_coninf_data.eth1 == "1" or g_coninf_data.eth2 == "1" or g_coninf_data.eth3 == "1") then
Led="1"
end
local LanArray={}
if not(config.DSL) and not(config.VDSL) and
not(config.DOCSIS) and not(config.LTE) then
if (g_coninf_data.eth1 == "1") then
table.insert(LanArray,"LAN")
end
else
local LanCount= config.ETH_COUNT
if ( LanCount>= 4) then
if (g_coninf_data.eth0 == "1") then
table.insert(LanArray,"LAN 1")
end
if (g_coninf_data.eth1 == "1") then
table.insert(LanArray,"LAN 2")
end
if (g_coninf_data.eth2 == "1") then
table.insert(LanArray,"LAN 3")
end
if (g_coninf_data.eth3 == "1") then
table.insert(LanArray,"LAN 4")
end
else
if (LanCount >= 2) then
if (g_coninf_data.eth0 == "1") then
table.insert(LanArray,"LAN 1")
end
if (g_coninf_data.eth1 == "1") then
table.insert(LanArray,"LAN 2")
end
else
if (g_coninf_data.eth0 == "1") then
table.insert(LanArray,"LAN")
end
end
end
end
local temp=""
if (#LanArray==1) then
temp=LanArray[1]
else
temp=table.concat(LanArray,", ")
end
if (temp=="") then
Displaytxt=[[{?537:724?}]]
else
Displaytxt=[[{?537:434?} (]]..temp..[[)]]
end
str=str..[[<tr id="uiTrLan">]]
str=str..[[<td class="]]..State_Led(Led)..[["></td>]]
str=str..[[<td><a href="]]..MajorLink..[[">LAN</a></td>]]
str=str.."<td>"..box.tohtml(Displaytxt).."</td>"
str=str.."</tr>"
return str
end
function get_devices_string(cnt, long)
if cnt == 1 then
if long then
return [[ {?537:723?}]]
end
return [[ {?537:576?}]]
end
if long then
return [[ {?537:682?}]]
end
return [[ {?537:540?}]]
end
function tr_connect_info_usbDevices()
local led="0"
local str=""
local total_number_of_dev = usb_devices.get_total_usb_devices_count()
local total_number_of_mem = usb_devices.get_usb_mem_devices_count(false)
local total_number_of_logvol = usb_devices.get_usb_mem_devices_count(true)
local displaytxt=""
local mem_txt = box.tohtml([[{?537:793?}]])
local no_device_txt = box.tohtml([[{?537:915?}]])
if (not any_usb_host) then
if config.USB then
displaytxt = box.tohtml([[{?537:664?}]])
if (g_coninf_data.usb_carrier=="1") then
led="1"
else
led="0"
displaytxt=no_device_txt
end
else
return ""
end
else
if total_number_of_dev == 0 then
led="0"
displaytxt = no_device_txt
elseif (total_number_of_dev > 0 and total_number_of_mem == 0) or
(store.aura_for_storage_aktiv()) or
(total_number_of_mem == 0 and (g_coninf_data.modem_present=="1" or g_coninf_data.morphstick_enabled =="1")) then
led="1"
displaytxt = box.tohtml([[{?537:354?}, ]] .. total_number_of_dev..get_devices_string(total_number_of_dev, false))
else
led="1"
displaytxt = box.tohtml([[{?537:631?}, ]])
if (total_number_of_logvol > 0) then
displaytxt = displaytxt .. [[<a href="]]..href.get_zone_link('nas')..[[">]]..box.tohtml(total_number_of_mem)..[[ ]]..mem_txt..[[</a> <a href="]]..href.get("/usb/usb_diskcut.lua","usbdev=all","back_to_page="..box.glob.script)..[[" onclick="return uiDoEjectUsb()">]]..box.tohtml([[({?537:189?})]])..[[</a>]]
else
displaytxt = displaytxt .. [[<span title="]]..box.tohtml([[{?537:836?}]])..[[">]]..box.tohtml(total_number_of_mem).." "..box.tohtml(mem_txt)..box.tohtml([[ ({?537:785?})]])..[[</span>]]
end
if total_number_of_mem ~= total_number_of_dev then
displaytxt = displaytxt..', '..box.tohtml((total_number_of_dev - total_number_of_mem)..get_devices_string((total_number_of_dev - total_number_of_mem), true))
end
end
end
str="<tr id='uiTrUsb'><td class='"..State_Led(led).."'></td>"
str=str.."<td><a href='"..href.get("/usb/show_usb_devices.lua").."'>"..box.tohtml([[{?537:484?}]])..[[</a></td>]]
return str.."<td>"..displaytxt.."</td></tr>"
end
function add_td_with_tooltip(Displaytxt, tooltip)
if not tooltip then
tooltip=string.gsub(Displaytxt,"<br>",", ")
end
return [[<td title="]] .. box.tohtml(tooltip) .. [[">]]..box.tohtml(Displaytxt)..[[</td>]]
end
g_ComfortTable={}
g_ComfortVisible=0
function check_comfort_counter()
local result= true
if ((g_countKomfort+1)>g_MaxKomfort) then
result= false
else
g_ComfortVisible=g_ComfortVisible+1
end
g_countKomfort=g_countKomfort+1
return result
end
local RemoveOnlyOneLine=true
function AddComfortFunc(comfort_str)
if comfort_str=="" then
return
end
if (g_countKomfort==g_ComfortVisible+1 and g_ComfortVisible==g_MaxKomfort and RemoveOnlyOneLine==false) then
for i=#g_ComfortTable,1,-1 do
if (string.find(g_ComfortTable[i],[[style=""]])) then
g_ComfortTable[i]=string.gsub(g_ComfortTable[i],[[style=""]],[[style="display:none;"]])
RemoveOnlyOneLine=true
break;
end
end
end
table.insert(g_ComfortTable,comfort_str)
end
function build_comfort_table()
AddComfortFunc(tr_fonbook_comfort())
AddComfortFunc(tr_call_redirect())
AddComfortFunc(tr_smart_home())
--WLAN Gastzugang jetzt unter Anschlüsse
AddComfortFunc(tr_wlan_guest_comf())
AddComfortFunc(tr_lan_guest())
AddComfortFunc(tr_alarmclock(1))
AddComfortFunc(tr_alarmclock(2))
AddComfortFunc(tr_alarmclock(3))
AddComfortFunc(tr_blockcalls())
AddComfortFunc(tr_myfritz())
AddComfortFunc(tr_port_fw())
AddComfortFunc(tr_ipv6_firewall())
AddComfortFunc(tr_nightlock())
AddComfortFunc(tr_intern_mem())
AddComfortFunc(IntFax_Display())
AddComfortFunc(tr_kids())
AddComfortFunc(tr_info_led())
AddComfortFunc(tr_remote_https())
AddComfortFunc(tr_calltrough())
AddComfortFunc(tr_online_cnt())
AddComfortFunc(tr_dyn_dns())
AddComfortFunc(tr_email())
end
function get_fonbook_symbol(itemtype)
if (itemtype=="intern") then
return "icon_device"
end
return "icon_person"
end
function get_fonbook_tooltip(itemtype)
if (itemtype=="intern") then
return box.tohtml([[{?537:553?}]])
end
return box.tohtml([[{?537:98?}]])
end
function ClickToDial(num,fonbook_name)
if (g_coninf_data.UseClickToDial~="1" or not g_coninf_data.right_to_dial) then
if (fonbook_name~="") then
return box.tohtml(fonbook_name)
end
return box.tohtml(num)
end
local str_call = general.sprintf([[{?537:781?}]],num)
local display_name = num
if (fonbook_name~="") then
str_call = general.sprintf([[{?537:707?}]],fonbook_name)
display_name = fonbook_name
end
local str=[[<a href='javascript:doRequest("dial","]]..box.tohtml(box.tojs(num))..[[");' title="]]..box.tohtml(str_call)..[[">]]..box.tohtml(display_name)..[[</a>]]
return str
end
function tr_fonbook_comfort()
if not config.FON then return "" end
require("fon_book")
local fonbook = fon_book.read_fonbook(0, 0, "name")
local fonbook_name = fon_book.bookname()
local MajorLink=href.get("/fon_num/fonbook_list.lua")
local title = tostring(#fonbook)..[[ {?537:637?}]]
if #fonbook==1 then
title = tostring(#fonbook)..[[ {?537:684?}]]
end
title=title..[[ {?537:979?} ]]..box.tohtml(fonbook_name)
local Displaytxt = [[<span title=']]..box.tohtml(title)..[['>]]..title..[[</span>]]
local str = '<tr id="uiFonbook">'
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:5626?}]])..[[</a></td>]]
str=str.."<td>"..Displaytxt.."</td>"
str=str.."</tr>"
return str
end
function tr_fonbook()
if not config.FON then return "" end
require("fon_book")
local fonbook = fon_book.read_fonbook(0, 8, "modified")
local Displaytxt=""
local MajorLink=href.get("/fon_num/fonbook_list.lua")
local str=""
local show=""
local numbers={}
if (#fonbook==0) then
Displaytxt=[[{?537:612?}]]
return [[<tr><td colspan="3">]]..Displaytxt..[[</td><tr>]]
else
for i,elem in ipairs(fonbook) do
if (i>g_MaxBlockInfo) then
break
end
str=str.."<tr>"
local itemtype="x"
local number=""
for idx,num in ipairs(elem.numbers or {}) do
if (num.number~=nil and num.prio==1) then
number=num.number
itemtype=num.type
end
end
if number == "" then
for idx,num in ipairs(elem.numbers or {}) do
if num.number~=nil and num.number~="" then
number=num.number
itemtype=num.type
break
end
end
end
str=str..[[<td class="]]..get_fonbook_symbol(itemtype)..[[" title="]]..get_fonbook_tooltip(itemtype)..[["></td>]]
str=str.."<td>"..box.tohtml(elem.name).."</td>"
str=str.."<td>"..ClickToDial(number,"").."</td>"
str=str.."</tr>"
end
end
return str
end
function tr_tamcalls()
if not config.FON then return "" end
if (not config.TAM_MODE or config.TAM_MODE==0)then return "" end
require"foncalls"
local tamcalls = foncalls.GetTamCalls(-1)
local tam_link = href.get("/fon_devices/tam_list.lua")
local str = [[<tr>]]
str = str .. [[<th class="home_head" colspan="5">]]
str = str .. [[<span class="head_link">]]
str = str .. [[<a href="]]..tam_link..[[">]]
str = str .. box.tohtml([[{?537:200?}]])
str = str .. [[</a>]]
str = str .. [[</span>]]
str = str .. [[<span class="more_link">]]
str = str .. [[<a href="]]..tam_link..[[">]]
str = str .. box.tohtml(general.sprintf([[{?txtmore_num?}]], tostring(#tamcalls)))
str = str .. [[</a>]]
str = str .. [[</span>]]
str = str .. [[</th>]]
str = str .. [[</tr>]]
local tam_configured=false
local any_tam_active=false
for i,elem in ipairs(g_coninf_data.Tam) do
if elem.display~="" and elem.display~="0" then
tam_configured=true
end
if elem.display=="1" and elem.active=="1" then
any_tam_active=true
end
end
if not tam_configured then
str = str .. [[
<tr>
<td colspan="5"><a href="]]..href.get([[/assis/assi_tam_intern.lua]],[[New_DeviceTyp=IntTam]],[[HTMLConfigAssiTyp=FonOnly]],[[Submit_Next=]],[[FonAssiFromPage=home]])..[[">]]..box.tohtml([[ {?537:263?}]])..[[</a></td>
</tr>
]]
return str
end
if not any_tam_active then
str = str .. [[
<tr>
<td colspan="5">]]..box.tohtml([[ {?537:459?}]])..[[</td>
</tr>
]]
end
if #tamcalls == 0 then
str = str .. [[
<tr>
<td colspan="5">]]..box.tohtml([[ {?537:9870?}]])..[[</td>
</tr>
]]
return str
end
local td_symbol = [[<td class="icon_tam" title="%s"></td>]]
local tds_date_time = [[<td>%s</td><td>%s</td>]]
local td_number = [[<td>%s</td>]]
local td_icon = [[<td style="text-align:right;"><a href="%s"><img title="%s" style="height:13px;width:13px" src="/css/default/images/icon_hear_call.gif"></a></td>]]
require"fon_devices"
for i, call in ipairs(tamcalls) do
if i > g_MaxBlockInfo then
break
end
str = str .. [[<tr>]]
str = str .. td_symbol:format(box.tohtml(fon_devices.get_tamname(call.tam) or ""))
local d, t = foncalls.date_shortdisplay(call)
str = str .. tds_date_time:format(box.tohtml(d), box.tohtml(t))
local txt = foncalls.number_shortdisplay(call)
if call.number == "" then
txt = box.tohtml(txt)
elseif call.name == "" then
txt = ClickToDial(call.number, "")
else
txt = ClickToDial(call.number, txt)
end
str = str .. td_number:format(txt)
if call.path then
str = str .. td_icon:format(
href.get([[/lua/photo.lua]], http.url_param("myabfile", call.path)),
box.tohtml([[{?537:567?}]])
)
else
str = str .. [[<td></td>]]
end
str = str .. [[</tr>]]
end
return str
end
function tr_myfritz()
if not config.MYFRITZ or g_coninf_data.opmode == "opmode_eth_ipclient" then
return ""
end
local myfritz_enabled = box.query("jasonii:settings/enabled") == "1"
local myfritz_email = box.query("jasonii:settings/user_email")
local Displaytxt=""
if (myfritz_email=="") then
return ""
else
if (not myfritz_enabled) then
return ""
end
Displaytxt=[[{?537:344?}: ]]..myfritz_email
end
require"menu"
local myfritz_share_visible=menu.check_page("internet", "/internet/myfritz_devicelist.lua")
if (myfritz_share_visible) then
require("myfritz_access")
local list,nr_of_shares=myfritz_access.read_list()
if (nr_of_shares==0) then
return ""
end
local tmp=[[{?537:219?}]]
if (not myfritz_access.is_any_share_active(list)) then
tmp=[[{?537:829?}]]
end
if (nr_of_shares==1) then
Displaytxt=general.sprintf([[{?537:432?}]],tmp)
else
Displaytxt=general.sprintf([[{?537:8556?}]],tmp,nr_of_shares)
end
end
local MajorLink=href.get("/internet/myfritz_devicelist.lua")
if not myfritz_share_visible then
MajorLink=href.get("/internet/myfritz.lua")
end
local str=""
local show=[[style=""]]
if (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
if g_coninf_data.opmode == "opmode_usb_modem" then
local tooltip = box.tohtml([[{?537:800?}]])
str=[[<tr id="trMyFritz" ]]..show..[[>]]
str=str..[[<td title=']]..tooltip..[['>{?537:291?}</td>]]
str=str..[[<td title=']]..tooltip..[['>]]..Displaytxt..[[</td>]]
str=str..[[</tr>]]
else
str=[[<tr id="trMyFritz" ]]..show..[[>]]
str=str..[[<td><a href="]]..MajorLink..[[">{?537:1631?}</a></td>]]
str=str..add_td_with_tooltip(box.tohtml(Displaytxt))
str=str..[[</tr>]]
end
return str
end
function tr_blockcalls()
local Displaytxt=[[{?537:353?}]]
local MajorLink=href.get("/fon_num/sperre.lua")
local str=""
local show=[[style=""]]
if (not general.is_callblockade_active(g_coninf_data)) then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
str=[[<tr id="trSperre" ]]..show..[[>]]
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:296?}]])..[[</a></td>]]
str=str.."<td>"..box.tohtml(Displaytxt).."</td>"
str=str.."</tr>"
return str
end
function tr_calltrough()
local Displaytxt="{?537:4362?}"
local MajorLink=href.get("/fon_num/callthrough.lua")
local str=""
local show=[[style=""]]
if (g_coninf_data.callthroughActive ~= "1") then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
str=[[<tr ]]..show..[[>]]
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:301?}]])..[[</a></td>]]
str=str.."<td>"..box.tohtml(Displaytxt).."</td>"
str=str.."</tr>"
return str
end
function tr_dyn_dns()
local Displaytxt=""
local MajorLink=href.get("/internet/dyn_dns.lua")
local str=""
local show=[[style=""]]
if (g_coninf_data.ddns_activated~="1") then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
local url=g_coninf_data.ddns_domain
local nState=tonumber(box.query("ddns:settings/account0/state")) or 0
local state_ipv4=[[, IPv4-]]..general.get_dyndns_state(nState)
local state_ipv6=""
if (config.IPV6 and g_coninf_data.ipv6_enabled=="1") then
local nState=tonumber(box.query("ddns:settings/account0/ip6state")) or 0
state_ipv6=[[, IPv6-]]..general.get_dyndns_state(nState)
end
if(url=="" or url=="er" or url==nil) then
Displaytxt=[[{?537:411?}]]
else
Displaytxt=general.sprintf([[{?537:109?}]],url)..state_ipv4..state_ipv6
end
str="<tr "..show..">"
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:64?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(box.tohtml(Displaytxt))
str=str.."</tr>"
return str
end
function IntFax_Display()
local Displaytxt=[[{?537:819?}]]
local MajorLink=href.get("/fon_devices/fondevices_list.lua")
if config.GUI_NEW_FAX then
MajorLink=href.get("/fon_devices/fax_send.lua")
end
local str=[[]]
local show=[[]]
if not g_coninf_data.intFaxActive or check_comfort_counter()==false then
show=[[style="display:none;"]]
end
str=[[<tr ]]..show..[[>]]
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:818?}]])..[[</a></td>]]
str=str..[[<td>]]..box.tohtml(Displaytxt)..[[</td>]]
str=str..[[</tr>]]
return str
end
function tr_remote_https()
local MajorLink=href.get("/internet/remote_https.lua")
local str=""
local show=[[style=""]]
local https = general.is_remote_https_active(g_coninf_data)
local ftp = not general.is_bridged_mode(g_coninf_data) and box.query("ctlusb:settings/storage-ftp-internet") == "1"
--if (general.is_remote_https_active(g_coninf_data)==false) then
if not https and not ftp then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
str=[[<tr ]]..show..[[>]]
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:413?}]])..[[</a></td>]]
local txt = [[{?537:16?} (%s)]]
local addtxt = {}
if https then table.insert(addtxt, "HTTPS") end
if ftp then table.insert(addtxt, "FTP") end
txt = txt:format(table.concat(addtxt, "/"))
str=str..add_td_with_tooltip(box.tohtml(txt))
str=str..[[</tr>]]
return str
end
function tr_info_led()
local Displaytxt=""
local MajorLink=href.get("/system/infoled.lua")
local str=""
local show=[[style=""]]
local reason = box.query("box:settings/infoled_reason")
if tonumber(reason) == nil or tonumber(reason) <= 0 or tonumber(reason)==14 then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
local tmp_msg=[[{?537:298?}]]
if config.FON and (config.TAM_MODE > 0) then
if config.FAX2MAIL then
tmp_msg=[[{?537:876?}]]
end
end
local reasonTab= {
["1"] = [[{?537:367?}]],
["3"] = [[{?537:752?}]],
["4"] = [[{?537:841?}]],
["5"] = [[{?537:601?}]],
["6"] = [[{?537:149?}]],
["7"] = [[{?537:757?}]],
["8"] = [[{?537:60?}]],
["9"] = [[{?537:919?}]],
["11"] = [[{?537:320?}]],
["12"] = [[{?537:127?}]],
["13"] = tmp_msg,
["15"] = [[{?537:692?}]],
["16"] = [[{?537:313?}]]
}
Displaytxt=reasonTab[reason]
if (Displaytxt==nil)then
Displaytxt=""
end
str="<tr "..show..">"
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:7464?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(box.tohtml(Displaytxt))
str=str.."</tr>"
return str
end
function tr_kids()
local Displaytxt=[[{?537:272?}]]
local MajorLink=href.get("/internet/kids_userlist.lua")
local str=""
local show=[[style=""]]
if (not general.is_router() or not general.is_kids_active(g_coninf_data)) then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
str="<tr "..show..">"
str=str..[[<td><a href="]]..MajorLink..[[">]]
str=str..box.tohtml([[{?537:616?}]])
str=str..[[</a></td>]]
str=str.."<td>"..box.tohtml(Displaytxt).."</td>"
str=str.."</tr>"
return str
end
function tr_nightlock()
if config.TIMERCONTROL then
return tr_nightlock_newstyle()
end
return ""
end
function tr_nightlock_newstyle()
local Displaytxt=""
local MajorLink=href.get("/system/wlan_night.lua")
local str=""
local show=[[style=""]]
local fonnacht = box.query("box:settings/night_time_control_ring_blocked")
if (g_coninf_data.NightlockEnabled ~= "1" and g_coninf_data.WlanNightlockEnabled~="1" and fonnacht ~= "1") then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
if(g_coninf_data.NightlockEnabled ~= "1" and g_coninf_data.WlanNightlockEnabled~="1" and fonnacht ~= "1") then
return ""
end
Displaytxt= [[{?537:285?}, ]]
local wlancontrolenabled= g_coninf_data.WlanNightlockEnabled
if (wlancontrolenabled == "1") then
if (fonnacht == "1") then
Displaytxt = [[{?537:342?}]]
else
if not g_coninf_data.WlanNightlockTimeplan then
Displaytxt = general.sprintf([[{?537:129?}]], g_coninf_data.WlanNightlockOfftime, g_coninf_data.WlanNightlockOntime)
else
Displaytxt = [[{?537:571?}]]
end
end
else
if (fonnacht == "1") then
MajorLink=href.get("/system/ring_block.lua")
Displaytxt = general.sprintf([[{?537:8974?} ]], g_coninf_data.NightlockOfftime, g_coninf_data.NightlockOntime)
else
return ""
end
end
str="<tr "..show..">"
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:164?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(box.tohtml(Displaytxt))
str=str.."</tr>"
return str
end
function tr_online_cnt()
local Displaytxt=""
local MajorLink=href.get("/internet/inetstat_counter.lua")
local str=""
local show=[[style=""]]
if general.is_onlinecounter_active(g_coninf_data)==false or
check_comfort_counter()==false then
show=[[style="display:none"]]
end
local bWarn,strWarn=general.is_budget_reached()
if (bWarn) then
Displaytxt=strWarn
else
local retstr, bshow=general.get_onlinecounter_amount()
if not bshow then
show=[[style="display:none"]]
end
Displaytxt=Displaytxt..retstr
end
str=[[<tr ]]..show..[[>]]
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:923?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(box.tohtml(Displaytxt))
str=str..[[</tr>]]
return str
end
function tr_port_fw()
local Displaytxt=""
local MajorLink=href.get("/internet/port_fw.lua")
local str=""
local show=[[style=""]]
if not general.is_router() or not(general.any_portrelease_info(g_coninf_data)) then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
local portrulecount=0
if (g_coninf_data.forwardrules~=nil) then
for i,elem in ipairs(g_coninf_data.forwardrules) do
if (elem.activated=="1") then
portrulecount=portrulecount+1
end
end
end
if(portrulecount>0) then
if(portrulecount==1) then
Displaytxt=Displaytxt..box.tohtml([[{?537:990?}, ]]..portrulecount..[[ {?537:25?}]])
else
Displaytxt=Displaytxt..box.tohtml([[{?537:32?}, ]]..portrulecount..[[ {?537:403?}]])
end
end
local UpnpPortArray={}
portrulecount=0
local exposed_host=g_coninf_data.use_exposed_host=="1" and g_coninf_data.exposed_host~=""
if (exposed_host) then
if (Displaytxt~="") then
Displaytxt=Displaytxt..", "
end
Displaytxt=Displaytxt..box.tohtml([[{?537:530?}: ]]..g_coninf_data.exposed_host)
end
local upnpportinfotext=""
if (g_coninf_data.upnp_activated=="1" and g_coninf_data.upnp_control_activated =="1") then
if (g_coninf_data.igdforwardrules~=nil) then
for i,elem in ipairs(g_coninf_data.igdforwardrules) do
portrulecount=portrulecount+1
local tmp=elem.protocol.." "..elem.port
table.insert(UpnpPortArray,tmp)
end
upnpportinfotext=table.concat(UpnpPortArray,", ")
end
end
if(portrulecount>0) then
if Displaytxt~="" then
Displaytxt=Displaytxt..", "
end
if(portrulecount==1) then
Displaytxt=Displaytxt..box.tohtml(portrulecount..[[ {?537:944?}]])
else
Displaytxt=Displaytxt..box.tohtml(portrulecount..[[ {?537:352?}]])
end
if(portrulecount<10) then
Displaytxt=Displaytxt.." ( "..box.tohtml(upnpportinfotext).." )."
end
end
str="<tr "..show..">"
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:321?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(Displaytxt)
str=str.."</tr>"
return str
end
function tr_ipv6_firewall()
local Displaytxt=""
local MajorLink=href.get("/internet/ipv6_fw.lua")
local str=""
local show=[[style=""]]
local count_rules = 0
for _, r in ipairs(g_coninf_data.ipv6firewall_rules) do
if r.enabled == "1" then count_rules = count_rules + 1 end
end
if not general.is_router() or g_coninf_data.ipv6_enabled ~= "1" or count_rules == 0 then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
if g_coninf_data.ipv6_enabled == "1" and count_rules > 0 then
Displaytxt = [[{?537:448?}]]
end
str="<tr "..show..">"
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:7973?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(box.tohtml(Displaytxt))
str=str.."</tr>"
return str
end
function tr_email()
local Displaytxt=""
local MajorLink=href.get("/system/push_list.lua")
local str=""
local show=[[style=""]]
if box.query("emailnotify:settings/infoenabled") ~= "1" then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
local EmailInterval=box.query("emailnotify:settings/interval")
if (EmailInterval=="daily") then
Displaytxt=[[{?537:959?}]]
elseif (EmailInterval=="weekly") then
Displaytxt=[[{?537:39?}]]
elseif (EmailInterval=="monthly") then
Displaytxt=[[{?537:701?}]]
end
str=[[<tr ]]..show..[[>]]
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:914?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(box.tohtml(Displaytxt))
str=str..[[</tr>]]
return str
end
require ("ha_func_lib")
function tr_smart_home()
local Displaytxt=""
local show=[[style=""]]
local MajorLink=href.get("/net/home_auto_overview.lua")
require("libaha")
local home_automation_list = aha.GetDeviceList()
local str=""
local consumption_total = 0
local all_devices, all_switch_devices, all_connected_switch_devices = ha_func_lib.get_device_counts( home_automation_list)
if all_connected_switch_devices > 0 then
Displaytxt=general.sprintf([[{?537:3337?} ]], all_connected_switch_devices)
str="<tr "..show.." title='"..box.tohtml(Displaytxt).."'>"
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:666?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(box.tohtml(Displaytxt))
str=str.."</tr>"
end
return str
end
function tr_call_redirect()
local Displaytxt=""
local MajorLink=href.get("/fon_num/rul_list.lua")
local str=""
local show=[[style=""]]
local activ_txt = [[{?537:24?}]]
local cnt_all, cnt_activ = general.is_call_rerouting_active(g_coninf_data)
if cnt_all==0 then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
local isAllIncoming=0;
if (g_coninf_data.CallerIdActions~=nil) then
for i,elem in ipairs(g_coninf_data.CallerIdActions) do
if (elem.CallerID=="" or elem.CallerID=="0") then
isAllIncoming=isAllIncoming+1
end
end
end
if (isAllIncoming==2 and cnt_all>0) then
cnt_all=cnt_all-1
end
if cnt_all > 0 and cnt_activ == 0 then
Displaytxt=[[{?537:80?}]]
elseif cnt_activ == 1 then
Displaytxt=activ_txt
else
Displaytxt=cnt_activ..' '..activ_txt
end
str="<tr "..show..">"
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:893?}]])..[[</a></td>]]
str=str.."<td>"..box.tohtml(Displaytxt).."</td>"
str=str.."</tr>"
return str
end
function tr_intern_mem()
if (not any_usb_host) then
return ""
end
local Displaytxt=""
local str=""
local show=[[style=""]]
local title=""
local global_capacity = 0
local global_used = 0
if not(check_comfort_counter()) then
show=[[style="display:none"]]
end
if not(store.speicher_nas_activ()) then
Displaytxt = box.tohtml([[{?537:739?}]])
else
if store.internal_memory_available() then
global_capacity = global_capacity + general.make_num(g_coninf_data.InternalMemCapacity)
global_used = global_used + general.make_num(g_coninf_data.InternalMemUsedSpace)
end
if store.check_usb_useable() then
local usb_dev = store.get_usb_devices_list()
for i,v in ipairs(usb_dev) do
global_capacity = global_capacity + general.make_num(v.capacity)
global_used = global_used + general.make_num(v.usedspace)
end
if (g_coninf_data.webdav_enabled=="1") then
global_capacity = global_capacity + general.make_num(g_coninf_data.storage_quota_avail)
global_used = global_used + general.make_num(g_coninf_data.storage_quota_used)
end
end
local p1 = 0
local p2 = 0
if (global_used / 1000000000) >= 1 then p1 = 1 end
if ((global_capacity - global_used) / 1000000000) >= 1 then p2 = 1 end
title = conv.humanReadable(global_used, "byte", p1, true, true)..[[ {?537:9068?}, ]]..conv.humanReadable(global_capacity - global_used, "byte", p2, true, true)..[[ {?537:506?}]]
Displaytxt = [[<span title=']]..box.tohtml(title)..[['><a href="]]..href.get_zone_link('nas')..[[">]]..title..[[</a></span>]]
if config.NAS and any_usb_host and g_ajax then
require("call_webusb")
local ret_table, err = call_webusb.call_webusb_func( "scan_info", 0 )
if err=="" and ret_table and ret_table[1] and ret_table[1].scan_status and ret_table[1].total_file_count then
if ret_table[1].scan_status == "scan running" then
Displaytxt = [[<span title=']]..box.tohtml(title)..[['>]]..box.tohtml([[{?537:913?}: ]])..ret_table[1].total_file_count..box.tohtml([[ {?537:229?}]])..[[</span>]]
elseif ret_table[1].scan_status == "update running" then
Displaytxt = [[<span title=']]..box.tohtml(title)..[['>]]..box.tohtml([[{?537:646?}]])..[[</span>]]
end
end
end
end
str='<tr id="uiViewTabSpeicherNas" '..show..'>'
str=str..[[<td><a href="]]..href.get("/storage/settings.lua")..[[">]]..box.tohtml([[{?537:880?}]])..[[</a></td>]]
str=str.."<td>"..Displaytxt.."</td>"
str=str.."</tr>"
return str
end
function tr_web_dav()
if not webdav.is_webdav_enabled() then
return ""
end
local MajorLink = href.get("/storage/settings.lua")
local Titeltxt = [[<a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:314?}]])..[[</a>]]
local Displaytxt = webdav.get_webdav_state()
local led = webdav.is_webdav_connected() and "1" or "0"
local str = ""
local str = [[<tr id="uiTrWebdav">]]
str = str .. [[<td class="]] .. State_Led(led) .. [["></td>]]
str = str .. [[<td>]] .. Titeltxt .. [[</td>]]
str = str .. [[<td>]] .. Displaytxt .. [[</td>]]
str = str .. [[</tr>]]
return str
end
function Time2Str(Time)
local str = tostring(Time)
return string.sub(str,0,2)..":"..string.sub(str,3)
end
function getbits(x,p)
return bit.maskand(x,p)
end
function Weekdays2Str(Weekdays)
local option = getbits(general.make_num(Weekdays),127)
local RetString = ""
if (option == 0) then
RetString =RetString..[[{?537:575?}]]
elseif (option == 127) then
RetString =RetString.. [[{?537:733?}]]
else
local tage = {}
if (bit.isset(option,0)) then
table.insert(tage,[[{?537:633?}]])
end
if (bit.isset(option,1)) then
table.insert(tage,[[{?537:698?}]])
end
if (bit.isset(option,2)) then
table.insert(tage,[[{?537:815?}]])
end
if (bit.isset(option,3)) then
table.insert(tage,[[{?537:671?}]])
end
if (bit.isset(option,4)) then
table.insert(tage,[[{?537:573?}]])
end
if (bit.isset(option,5)) then
table.insert(tage,[[{?537:90?}]])
end
if (bit.isset(option,6)) then
table.insert(tage,[[{?537:661?}]])
end
RetString = [[{?537:950?} ]]
if (#tage>1) then
local Lastday=tage[#tage]
tage[#tage]=nil
RetString = RetString..table.concat(tage,", ")
RetString = RetString..[[ {?537:122?} ]]..Lastday
else
RetString = RetString..table.concat(tage,", ")
end
end
return RetString
end
function get_alarmclocktxt(Active,Time,Num,Weekdays)
require("fon_devices")
if (Active=="") then
return ""
end
if (Active == "0") then
return ""
end
local str=""
if (Num == "50" or Num=="9") then
str= fon_devices.get_fonname(Num,g_coninf_data)..[[ {?537:246?}]]
else
str= fon_devices.get_fonname(Num,g_coninf_data)..[[ {?537:475?}]]
end
return box.tohtml(general.sprintf(str, Weekdays2Str(Weekdays), Time2Str(Time)))
end
function tr_alarmclock(IdOfAlarmclock)
if not(config.FON) then
return ""
end
local Displaytxt=""
local MajorLink=""
local str=""
local show=[[style=""]]
if (IdOfAlarmclock==1 and g_coninf_data.Alarmclock1Active~="1") then
show=[[style="display:none"]]
elseif (IdOfAlarmclock==2 and g_coninf_data.Alarmclock2Active~="1") then
show=[[style="display:none"]]
elseif (IdOfAlarmclock==3 and g_coninf_data.Alarmclock3Active~="1") then
show=[[style="display:none"]]
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
local Active = ""
local Time = ""
local Num = ""
local Weekdays = ""
if (g_coninf_data.Alarmclock1Active == "1" and IdOfAlarmclock==1) then
Active = g_coninf_data.Alarmclock1Active
Time = box.query("telcfg:settings/AlarmClock0/Time")
Num = box.query("telcfg:settings/AlarmClock0/Number")
Weekdays = box.query("telcfg:settings/AlarmClock0/Weekdays")
MajorLink=href.get("/fon_devices/alarm.lua","tab=0")
end
if (g_coninf_data.Alarmclock2Active == "1" and IdOfAlarmclock==2) then
Active = g_coninf_data.Alarmclock2Active
Time = box.query("telcfg:settings/AlarmClock1/Time")
Num = box.query("telcfg:settings/AlarmClock1/Number")
Weekdays = box.query("telcfg:settings/AlarmClock1/Weekdays")
MajorLink=href.get("/fon_devices/alarm.lua","tab=1")
end
if (g_coninf_data.Alarmclock3Active == "1" and IdOfAlarmclock==3) then
Active = g_coninf_data.Alarmclock3Active
Time = box.query("telcfg:settings/AlarmClock2/Time")
Num = box.query("telcfg:settings/AlarmClock2/Number")
Weekdays = box.query("telcfg:settings/AlarmClock2/Weekdays")
MajorLink=href.get("/fon_devices/alarm.lua","tab=2")
end
Displaytxt=get_alarmclocktxt(Active,Time,Num,Weekdays)
if (Displaytxt=="") then
return ""
end
str='<tr '..show..'>'
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:804?} ]]..tostring(IdOfAlarmclock))..[[</a></td>]]
str=str..add_td_with_tooltip(Displaytxt)
str=str.."</tr>"
return str
end
function get_time_str()
local time=tonumber(g_coninf_data.wlanguest_time_remain)
local str = ""
local rest_time_min_sing = [[{?537:1256?}]]
local rest_time_hour_sing = [[{?537:1193?}]]
local rest_time_min_plu = [[{?537:4337?}]]
local rest_time_hour_plu = [[{?537:849?}]]
if time and time > 0 then
local calc_time = time/60
if time < 91 or calc_time < 1 then
str = ', '..time..' '
if time == 1 then
str = str..rest_time_min_sing
elseif time > 1 then
str = str..rest_time_min_plu
end
else
str = ', '..string.format("%.0f", calc_time)..' '
if calc_time == 1 then
str = str..rest_time_hour_sing
elseif calc_time > 1 then
str = str..rest_time_hour_plu
end
end
end
return str
end
function tr_wlan_guest_comf()
require"menu"
if not menu.check_page("wlan", "/wlan/guest_access.lua") then
return ""
end
local guest_ssid=box.query("wlan:settings/guest_ssid")
local guest_pwd=box.query("wlan:settings/guest_pskvalue")
if (guest_pwd=="") then
return ""
end
local wlan_Enabled=g_coninf_data.ap_enabled == "1" or g_coninf_data.ap_enabled_scnd == "1"
local Displaytxt=""
local str=""
local show=[[style=""]]
local MajorLink=href.get("/wlan/guest_access.lua")
if (not wlan_Enabled)then
return ""
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
Displaytxt=[[{?537:58?} (]]
if ( g_coninf_data.wlanguest_active~="1") or g_coninf_data.wlan_config_status == "fail" then
Displaytxt=[[{?537:428?}]]
else
if g_coninf_data.ap_enabled and g_coninf_data.ap_enabled == "1" then
if g_coninf_data.bg_mode=="52" then
Displaytxt=Displaytxt..'5'
else
Displaytxt=Displaytxt..'2,4'
end
end
if g_coninf_data.ap_enabled_scnd and g_coninf_data.ap_enabled_scnd == "1" then
if g_coninf_data.ap_enabled and g_coninf_data.ap_enabled == "1" then
Displaytxt=Displaytxt..'/'
end
Displaytxt=Displaytxt..'5'
end
Displaytxt=Displaytxt..' GHz)'
if tonumber(g_coninf_data.wlanguest_encryt) and tonumber(g_coninf_data.wlanguest_encryt) ~= 0 then
Displaytxt=Displaytxt..[[, {?537:5452?}]]
else
Displaytxt=Displaytxt..[[, {?537:231?}]]
end
Displaytxt=Displaytxt..get_time_str()
local guest_clients = get_wlan_clients(true)
Displaytxt=Displaytxt..', '..tostring(guest_clients)
if guest_clients == 1 then
Displaytxt=Displaytxt..[[ {?537:630?}]]
else
Displaytxt=Displaytxt..[[ {?537:401?}]]
end
Displaytxt=Displaytxt..", "..general.sprintf([[{?537:653?}]], guest_ssid)
end
str="<tr "..show.." title='"..box.tohtml(Displaytxt).."'>"
str=str..[[<td title="]]..box.tohtml([[{?537:2793?}]])..[["><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:543?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(Displaytxt)
str=str.."</tr>"
return str
end
function tr_lan_guest()
local lan_Enabled=box.query("box:settings/ethernet_guest_enabled") == "1"
local Displaytxt=""
local str=""
local show=[[style=""]]
local MajorLink=href.get("/net/network_settings.lua")
if (not lan_Enabled)then
return ""
elseif (check_comfort_counter()==false) then
show=[[style="display:none"]]
end
Displaytxt=[[{?537:253?}]]
str="<tr "..show.." title='"..box.tohtml(Displaytxt).."'>"
str=str..[[<td><a href="]]..MajorLink..[[">]]..box.tohtml([[{?537:487?}]])..[[</a></td>]]
str=str..add_td_with_tooltip(box.tohtml(Displaytxt))
str=str.."</tr>"
return str
end
local function tr_activecall(call)
if not config.FON then return "" end
require("foncalls")
local str = ""
local td_symbol = [[<td class="%s" title="%s"></td>]]
local td_port = [[<td colspan="2">%s</td>]]
local td_number = [[<td class="%s" title="%s">%s</td>]]
local td_duration = [[<td>%s</td>]]
local ctype = foncalls.calltype(call)
local symbol = foncalls.get_callsymbol(ctype)
local num_display = foncalls.number_homedisplay(call)
str = str .. [[<tr>]]
str = str .. td_symbol:format(symbol.class or "", box.tohtml(symbol.txt))
str = str .. td_port:format(box.tohtml(foncalls.port_display(call)))
str = str .. td_number:format(symbol.dirclass or "", box.tohtml(num_display), box.tohtml(num_display))
str = str .. td_duration:format(box.tohtml(call.duration))
str = str .. [[</tr>]]
return str
end
local function td_number_display(call)
if not config.FON then return "" end
require("foncalls")
local str = ""
local txt = foncalls.number_homedisplay(call)
if call.number == "" then
txt = box.tohtml(txt)
elseif call.name == "" then
txt = ClickToDial(call.number, "")
else
txt = ClickToDial(call.number, txt)
end
local colspan = ""
if not foncalls.addable_to_fonbook(call) then
colspan = [[ colspan="2"]]
end
local td_number = [[<td%s>%s</td>]]
str = str .. td_number:format(colspan, txt)
if colspan == "" then
require("fon_book")
local td_icon = [[
<td style="text-align:right;"><a href="%s"><img title="%s" src="/css/default/images/icon_fonbook_add.png"></a></td>]]
str = str .. td_icon:format(
fon_book.addnum_link(call.number, call.name),
box.tohtml([[{?537:228?}]])
)
end
return str
end
local function tr_call(call)
if not config.FON then return "" end
require("foncalls")
local str = ""
local ctype = foncalls.calltype(call)
local symbol = foncalls.get_callsymbol(ctype)
str = str .. [[<tr>]]
local td_symbol = [[<td class="%s" title="%s"></td>]]
str = str .. td_symbol:format(symbol.class or "", box.tohtml(symbol.txt))
local d, t = foncalls.date_shortdisplay(call)
local td_date_time = [[<td>%s</td><td>%s</td>]]
str = str .. td_date_time:format(box.tohtml(d), box.tohtml(t))
str = str .. td_number_display(call)
str = str .. [[</tr>]]
return str
end
function tr_foncalls()
if not config.FON then return "" end
require("foncalls")
local str = [[<tr>]]
str = str .. [[<th class="home_head" colspan="5">]]
str = str .. [[<span class="head_link">]]
str = str .. [[<a href="]]..href.get("/fon_num/foncalls_list.lua")..[[">]]
str = str .. box.tohtml([[{?537:759?}]])
str = str .. [[</a>]]
str = str .. [[</span>]]
str = str .. [[<span class="details">]]
str = str .. box.tohtml(string.format([[(%s %s)]],
[[{?537:891?}]], tostring(foncalls.count_today())
))
str = str .. [[</span>]]
str = str .. [[<span class="icon_head">]]
str = str .. [[<img src="/css/default/images/icon_fonbook.png">]]
str = str .. [[</span>]]
str = str .. [[<span class="more_link">]]
str = str .. [[<a href="]]..href.get('/fon_num/foncalls_list.lua')..[[">]]
str = str .. box.tohtml(
general.sprintf([[{?txtmore_num?}]], tostring(foncalls.count_all()))
)
str = str .. [[</a>]]
str = str .. [[</span>]]
str = str .. [[</th>]]
str = str .. [[</tr>]]
local activecalls = foncalls.get_activecalls()
local calls = foncalls.get_all(g_MaxBlockInfo - #activecalls)
if #activecalls + #calls == 0 then
str = str .. [[<tr><td colspan="5">]]
str = str .. box.tohtml([[{?537:480?}]])
str = str .. [[</td></tr>]]
return str
end
for i, call in ipairs(activecalls) do
str = str .. tr_activecall(call)
end
for i, call in ipairs(calls) do
str = str .. tr_call(call)
end
return str
end
function tr_fon_device(device)
if (device==nil) then
return ""
end
local str="<tr>"
str = str.."<td>"..box.tohtml(tostring(device.name)).."</td>"
str = str.."<td>**"..box.tohtml(tostring(device.intern)).."</td>"
str = str.."<td>"..box.tohtml(tostring(device.number)).."</td>"
str = str.."</tr>"
return str
end
function tr_fon_devices ()
require("fon_devices")
local phones, phone_cnt = fon_devices.get_all_fon_devices()
local doShow = true
local doShowIsdnDefault = fon_devices.showIsdnDefault()
local NumOfFonDev=0
local str=""
if (phones~=nil and phone_cnt > 0) then
for i,elem in ipairs(phones) do
doShow = true;
if (fon_devices.isIsdnDefault(elem)) then
doShow = doShowIsdnDefault;
end
if (doShow) then
if (NumOfFonDev<g_MaxBlockInfo) then
str=str..tr_fon_device(elem)
end
NumOfFonDev=NumOfFonDev+1
if NumOfFonDev==g_MaxBlockInfo then
break;
end
end
end
end
if (NumOfFonDev==0) then
return [[<tr><td colspan="3">]]..box.tohtml([[{?537:425?}]])..[[</td></tr>]]
end
return str
end
function netsymbol_title(device)
if (device==nil) then
return ""
end
if (device.guest=="1") then
if (device.online=="1") then
return [[{?537:968?}]]
end
return [[{?537:510?}]]
end
if (device.online=="1") then
return [[{?537:797?}]]
end
if device.parental_control_abuse == "1" then
return [[{?537:370?}]]
end
return [[{?537:386?}]]
end
function netsymbol(device)
local ret_class=""
if device then
if device.online=="1" and device.active=="1" then
if device.guest=="1" then
ret_class="globe_online_guest"
else
ret_class="globe_online"
end
elseif device.active=="1" then
if device.parental_control_abuse == "1" then
ret_class = "dev_blocked"
elseif device.guest=="1" then
ret_class="led_green_guest"
else
ret_class="led_green"
end
end
end
return ret_class
end
function tr_net_device(device)
if (device==nil or (device.active~="1")) then
return ""
end
if config.WLAN_WDS2 and device.wlan_station_type == "wds_slave" then
return ""
end
local withLink = (device.type == 'wlan')
withLink = false
local ip = "-"
local connect_type="-"
if (device.ip~=nil and device.ip~="") then
ip=device.ip
end
if (device.type=="ethernet") then
connect_type="LAN"
elseif (device.type=="wlan") then
connect_type="WLAN"
elseif (device.type == "plc") then
connect_type="PLC"
end
local str = "<tr>"
str = str..[[<td class="]]..netsymbol(device)..[[" title="]]..box.tohtml(netsymbol_title(device))..[[">]]
if (withLink) then
str = str..[[<a href="]]..href.get("/wlan/wlan_settings.lua")..[[">&nbsp;&nbsp;&nbsp;</a>]]
end
str = str.."</td>"
str = str.."<td>"..net_devices.get_displayname_with_link(device).."</td>"
str = str.."<td>"..connect_type.."</td>"
str = str.."</tr>"
return str
end
function tr_net_devices()
require("net_devices")
local str = ""
str = str .. [[<tr>]]
str = str .. [[<th class="home_head" colspan="3">]]
local link = href.get("/net/network_user_devices.lua")
str = str .. [[<span class="head_link">]]
str = str .. [[<a href="]]..link..[[">]]..box.tohtml([[{?537:625?}]])..[[</a>]]
str = str .. [[</span>]]
str = str .. [[<span class="more_link">]]
str = str .. [[<a href="]]..link..[[">]]
local more_count = #net_devices.g_list
str = str .. box.tohtml(general.sprintf([[{?txtmore_num?}]], more_count))
str = str .. [[</a>]]
str = str .. [[</span>]]
str = str .. [[</th>]]
str = str .. [[</tr>]]
local NumOfNetDev=0
local NumOfNetDevToShow=0
local dev_str = [[]]
if (net_devices.g_list~=nil) then
for i,elem in ipairs(net_devices.g_list) do
if (NumOfNetDevToShow<g_MaxBlockInfo) then
local result = tr_net_device(elem)
if (result~="") then
NumOfNetDevToShow=NumOfNetDevToShow+1
dev_str=dev_str..result
end
end
NumOfNetDev=NumOfNetDev+1
if NumOfNetDevToShow==g_MaxBlockInfo then
break;
end
end
end
if (NumOfNetDev==0) then
return str..[[<tr><td colspan="3">]]..box.tohtml([[{?537:587?}]])..[[</td></tr>]]
end
if (NumOfNetDevToShow==0) then
return str..[[<tr><td colspan="3">]]..box.tohtml([[{?537:734?}]])..[[</td></tr>]]
end
return str..dev_str
end
function get_more_link(which)
local str = ""
local net_link='/net/network_user_devices.lua'
if which == 'net' then
require"net_devices"
str=str..[[ <a class="cs_more_top" href="]]..href.get(net_link)..[[">]]..box.tohtml(general.sprintf([[{?txtmore_num?}]],#net_devices.g_list))..[[</a>]]
elseif which == 'net3' then
require"net_devices"
str=str..[[ <a class="cs_more_top" href="]]
str=str..href.get(net_link)
str=str..box.tohtml(general.sprintf([[">{?txtmore_num?}]],net_devices.get_count()))..[[</a>]]
elseif which == 'calls' and config.FON then
require("foncalls")
str=str..[[ <a class="cs_more_top" href="]]..href.get('/fon_num/foncalls_list.lua')..[[">]]..box.tohtml(general.sprintf([[{?txtmore_num?}]], tostring(foncalls.count_all())))..[[</a>]]
elseif which == 'fonbook' and config.FON then
require("fon_book")
str=str..[[ <a class="cs_more_top" href="]]..href.get('/fon_num/fonbook_list.lua')..[[">]]..box.tohtml([[{?txtmore?}]])..[[</a>]]
str = str..[[<a class="cs_more_top" href="]]..fon_book.addnum_link('','')..[[">]]
str = str..[[<img title="]]..box.tohtml([[{?537:945?}]])..[[" src="/css/default/images/icon_fonbook.gif">]]
str = str..[[</a>]]
elseif which == 'tamcalls' and config.FON then
require("foncalls")
local count = #foncalls.GetTamCalls(-1)
count = general.sprintf([[{?txtmore_num?}]], tostring(count))
str=str..[[ <a class="cs_more_top" href="]]..href.get('/fon_num/foncalls_list.lua')..[[">]]
str=str..box.tohtml(count)
str=str..[[</a>]]
elseif which == 'comfort' then
if not g_no_comfort_link then
if g_countKomfort > g_MaxKomfort or g_show_full_comfort then
str=str..[[<a id="uiViewComfortLinkx" class="cs_more_top" href="javascript:set_Comfort();">]]
if g_show_full_comfort then
str=str..box.tohtml([[{?537:262?}]])
else
str=str..box.tohtml(general.sprintf([[{?txtmore_num?}]],tostring(g_countKomfort)))
end
str=str..[[</a>]]
end
end
end
return str
end
function get_comfort_link()
if g_no_comfort_link then
return ""
end
if g_countKomfort<=g_MaxKomfort and not(g_show_full_comfort) then
return ""
end
local str =[[<div id="uiShowAllKomfort" style="height: 13px; padding: 3px 0px 1px 0px;">]]
str=str..[[<a id="uiViewComfortLink" class="cs_more" href="javascript:set_Comfort();"><span id="uiShowKomfort">]]
if (g_show_full_comfort) then
str=str..box.tohtml([[{?537:2580?}]])
else
str=str..box.tohtml(general.sprintf([[{?txtmore_num?}]],tostring(g_countKomfort)))
end
str=str..[[</span></a>]]
str=str..[[<span class="cs_count" id="uiKomfortCount"> </span></div>]]
return str
end
function IsFonActive(TableType)
if not(config.FON) then
if (TableType=="OnlyLan") then
return ""
end
return "display:none"
end
if (TableType=="all") then
return ""
end
if (TableType=="OnlyLan") then
return "display:none"
end
return ""
end
if (box.get.query~=nil) then
box.out([[{"html":]])
if (box.get.query=="dial") then
if (box.get.action=="dial") then
require("fon_devices")
require("cmtable")
box.out([["empty",]])
require"js"
box.out([["dialingport":]]..js.quoted(fon_devices.GetFonDeviceName(tostring(box.query("telcfg:settings/DialPort"))))..[[,]])
box.out([["dialing":]]..js.quoted(tostring(box.get.number))..[[]])
local saveset = {}
cmtable.add_var(saveset, "telcfg:command/Dial", box.get.number)
local err_code, err_msg = box.set_config(saveset)
elseif (box.get.action=="hangup") then
require("cmtable")
box.out([["empty",]])
box.out([["dialingport":"",]])
box.out([["dialing":"hangup"]])
local saveset = {}
cmtable.add_var(saveset, "telcfg:command/Hangup", "")
local err_code, err_mgs = box.set_config(saveset)
else
box.out([["empty",]])
box.out([["dialingport":"",]])
box.out([["dialing":"unknown"]])
end
end
box.out("}")
box.end_page()
end
function get_heading(which)
local str = ""
if which == 'ppp' then
str=str..[[<h4 class="homelua" style="margin-top:3px;">]]..box.tohtml([[{?537:162?}]])..[[</h4>]]
elseif which == 'connections' then
str=str..[[<td style="width:376px;background-color:#faf8f2;">]]
str=str..[[<h4 class="homelua">]]..box.tohtml([[{?537:392?}]])..[[</h4>]]
str=str..[[</td>]]
elseif which == 'comfort' then
str=str..[[<td style="width:378px;background-color:#faf8f2;">]]
str=str..[[<h4 class="homelua">]]
str=str..[[<span style="float:left;">]]..box.tohtml([[{?537:639?}]])..[[</span>]]
str=str..get_more_link('comfort')
str=str..[[</h4>]]
str=str..[[</td>]]
elseif which == 'net3' then
str=str..[[<td style="background-color:#faf8f2;">]]
str=str..[[<h4 class="homelua">]]
str=str..[[<a class="head_link" href="]]..href.get('/net/network_user_devices.lua')..[[">]]
str=str..box.tohtml([[{?537:2930?}]])
str=str..[[</a>]]
str=str..get_more_link('net3')
str=str..[[</h4>]]
str=str..[[</td>]]
elseif which == 'calls' and config.FON then
require("foncalls")
str=str..[[<td style="width:242px;background-color:#faf8f2;">]]
str=str..[[<h4 class="homelua">]]
str=str..[[<a class="head_link" href="]]..href.get('/fon_num/foncalls_list.lua')..[[">]]..box.tohtml([[{?537:741?}]])..[[</a>]]
str=str..[[<span class="cs_Details">]]..box.tohtml([[ ({?537:91?} ]]..tostring(foncalls.count_today()))..[[)</span>]]
str=str..get_more_link('calls')
str=str..[[</h4>]]
str=str..[[</td>]]
elseif which == 'net' then
str=str..[[<td style="width:242px;background-color:#faf8f2;">]]
str=str..[[<h4 class="homelua">]]
str=str..[[<a class="head_link" href="]]..href.get('/net/network_user_devices.lua')..[[">]]
str=str..box.tohtml([[{?537:177?}]])..[[</a>]]
str=str..get_more_link('net')
str=str..[[</h4>]]
str=str..[[</td>]]
elseif which == 'tamcalls' and config.FON then
str=str..[[<td style="width:242px;background-color:#faf8f2;">]]
str=str..[[<h4 class="homelua">]]
str=str..[[<a class="head_link" href="]]..href.get('/fon_num/foncalls_list.lua')..[[">{?537:349?}</a>]]
str=str..get_more_link('tamcalls')
str=str..[[</h4>]]
str=str..[[</td>]]
end
return str
end
function create_page_content()
local str=""
str=str..[[<table id="tProdukt" class="tborder">]]
str=str..[[ <tr>]]
local fname=box.query("box:settings/hostname")
if (fname~="") then
str=str..[[ <td style="width:374px;" >]]..box.tohtml(g_Productname)..[[, ]]..box.tohtml(fname)..[[</td>]]
else
str=str..[[ <td style="width:374px;" >]]..box.tohtml(g_Productname)..[[</td>]]
end
str=str..[[ <td style="width:377px;" class="td_right">]]
str=str..[[<a target="_blank" onclick="fbosPopup(this.href);return false;" href="]]..href.get('/home/pp_fbos.lua')..[[">]]
str=str..box.tohtml(g_Firmware_Version[1])
str=str..[[ ]]
str=str..box.tohtml(g_Firmware_Version[2])
str=str..[[</a>]]
str=str..[[</td>]]
str=str..[[ </tr>]]
str=str..tr_produkt_info()
str=str..tr_not_signed()
str=str..tr_provider_defaults()
str=str..[[</table>]]
str=str..get_heading('ppp')
str=str..[[<table id="tPpp" class="tborder">]]
str=str..[[ <colgroup>]]
str=str..[[ <col width="16px">]]
str=str..[[ <col width="96px">]]
str=str..[[ <col width="auto">]]
str=str..[[ </colgroup>]]
str=str..tr_RepeaterWlan()
str=str..tr_internet()
str=str..tr_internet_Ipv6()
str=str..tr_internet_Sips()
str=str..tr_web_dav()
str=str..[[</table>]]
str=str..[[<table id="tTab_Container1" style="padding:0;position:relative;left:-2px;" >]]
str=str..[[ <tr>]]
build_comfort_table()
str=str..get_heading('connections')
str=str..[[ <td style="width:1px;background-color:#faf8f2;"></td>]]
str=str..get_heading('comfort')
str=str..[[ </tr>]]
str=str..[[ <tr>]]
str=str..[[ <td class="tborder" style="padding:2px" >]]
str=str..[[ <table id="tAnsch" style="width:367px">]]
str=str..[[ <colgroup>]]
str=str..[[ <col width="8px">]]
str=str..[[ <col width="42px">]]
str=str..[[ <col width="107px">]]
str=str..[[ </colgroup>]]
str=str..tr_connect_info_plc()
str=str..tr_connect_info_dsl()
str=str..tr_connect_info_lan()
if config.GUI_IS_REPEATER and config.WLAN.is_double_wlan then
str=str..tr_connect_info_wlan("24")
str=str..tr_connect_info_wlan("5")
else
str=str..tr_connect_info_wlan()
end
str=str..tr_connect_info_smarthome()
str=str..tr_connect_info_dect()
str=str..tr_connect_info_usbDevices()
str=str..[[ </table>]]
str=str..[[ </td>]]
str=str..[[ <td></td>]]
str=str..[[ <td class="tborder" style="padding:2px">]]
str=str..[[ <table id="tKomfort" style="width:373px" >]]
str=str..[[ <colgroup>]]
str=str..[[ <col width="75px">]]
str=str..[[ <col width="135px">]]
str=str..[[ </colgroup>]]
str=str..table.concat(g_ComfortTable," ")
str=str..[[ </table>]]
str=str..[[ </td>]]
str=str..[[ </tr>]]
str=str..[[</table><!-- tTab_Container1 -->]]
str=str..[[<table id="tTab_Container3" style="padding:0;position:relative;left:-2px;]]..IsFonActive('OnlyLan')..[[" >]]
str=str..[[ <tr>]]
str=str..[[ <td class="tborder">]]
str=str..[[ <div id="tNet3div">]]
str=str..[[ <table id="tNet3">]]
str=str..[[ <colgroup>]]
str=str..[[ <col width="20px">]]
local islong=false
if (islong) then
str=str..[[ <col width="701px">]]
else
str=str..[[ <col width="318px">]]
end
str=str..[[ <col width="40px">]]
str=str..[[ </colgroup>]]
str=str..tr_net_devices()
str=str..[[ </table>]]
str=str..[[ </div>]]
str=str..[[ </td>]]
str=str..[[ </tr>]]
str=str..[[</table>]]
str=str..[[<table id="tTab_Container2" style="padding:0;position:relative;left:-2px;]]..IsFonActive('all')..[[" >]]
str=str..[[ <tr>]]
if ( config.TAM_MODE and config.TAM_MODE>0) then
str=str..[[ <td class="tborder">]]
else
str=str..[[ <td class="tborder" style="width:373px">]]
end
str=str..[[ <div id="tCallsdiv">]]
if ( config.TAM_MODE and config.TAM_MODE>0) then
str=str..[[ <table id="tCalls" style="width:248px">]]
else
str=str..[[ <table id="tCalls" style="width:373px" >]]
end
str=str..[[ <colgroup>]]
str=str..[[ <col width="16px">]]
str=str..[[ <col width="32px">]]
str=str..[[ <col width="26px">]]
str=str..[[ <col width="64px">]]
str=str..[[ <col width="18px">]]
str=str..[[ </colgroup>]]
str=str..tr_foncalls()
str=str..[[ </table>]]
str=str..[[ </div>]]
str=str..[[ </td>]]
str=str..[[ <td style="width:1px;background-color:#faf8f2;"></td>]]
if ( config.TAM_MODE and config.TAM_MODE>0) then
str=str..[[ <td class="tborder">]]
else
str=str..[[ <td class="tborder" style="width:378px">]]
end
str=str..[[ <div id="tNetdiv">]]
if ( config.TAM_MODE and config.TAM_MODE>0) then
str=str..[[ <table id="tNet" style="width:248px">]]
else
str=str..[[ <table id="tNet" style="width:378px">]]
end
str=str..[[ <colgroup>]]
str=str..[[ <col width="16px">]]
str=str..[[ <col width="135px">]]
str=str..[[ <col width="40px">]]
str=str..[[ </colgroup>]]
str=str..tr_net_devices()
str=str..[[ </table>]]
str=str..[[ </div>]]
str=str..[[ </td>]]
str=str..[[ <td style="width:1px;background-color:#faf8f2;"></td>]]
if ( config.TAM_MODE and config.TAM_MODE>0) then
str=str..[[ <td class="tborder">]]
str=str..[[ <div id="tTamcallsdiv">]]
str=str..[[ <table id="tTamcalls" style="width:248px">]]
str=str..[[ <colgroup>]]
str=str..[[ <col width="16px">]]
str=str..[[ <col width="32px">]]
str=str..[[ <col width="26px">]]
str=str..[[ <col width="64px">]]
str=str..[[ <col width="18px">]]
str=str..[[ </colgroup>]]
str=str..tr_tamcalls()
str=str..[[ </table>]]
str=str..[[ </div>]]
str=str..[[ </td>]]
end
str=str..[[ </tr>]]
str=str..[[</table><!-- tTab_Container2 -->]]
return str
end
if g_ajax then
box.out(create_page_content())
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#tPpp,
#tProdukt,
#tTab_Container1,
#tTab_Container2,
#tTab_Container3{
width:765px;
table-layout:fixed;
overflow:hidden;
border-collapse:separate;
}
#tTab_Container1, #tTab_Container2,
#tTab_Container3,
#tAnsch, #tKomfort, #tNet, #tNet3,
#tFonDevices, #tCalls, #tFonbook, #tTamcalls {
table-layout:fixed;
border:0px;
overflow:hidden;
}
#tAnsch, #tKomfort, #tNet, #tNet3,
#tFonDevices, #tCalls, #tFonbook, tTamcalls {
padding:2px;
}
#tNetdiv, #tCallsdiv, #tFonDevicesdiv, #tFonbookdiv, tTamcallsdiv, #tNet3div {
height: <?lua box.out(tostring(22 + g_MaxBlockInfo*18).."px") ?>;
}
#tPpp td, #tProdukt td, #tAnsch td,
#tKomfort td, #tNet td, #tFonDevices td, #tNet3 td,
#tCalls td , #tFonbook td, #tTamcalls td {
vertical-align:top;
white-space:pre;
overflow:hidden;
text-overflow: ellipsis;
-o-text-overflow: ellipsis;
}
#tTab_Container1 td, #tTab_Container2 td , #tTab_Container3 td{
vertical-align:top;
overflow:hidden;
background-color: #ffffff;
text-overflow: ellipsis;
-o-text-overflow: ellipsis;
}
<?lua
local islong=false
if (islong) then
box.out([[
#tTab_Container3 {
background-color: #faf8f2;
width:769px;
}
#uiNetInfo3 {
width:757px;
}
]])
else
box.out([[
#tTab_Container3 {
width:382px;
background-color: #faf8f2;
}
#uiNetInfo3 {
width:370px;
}
]])
end
?>
#tTab_Container2, #tTab_Container1 {
width:769px;
background-color: #faf8f2;
}
.tborder {
vertical-align: top;
}
.cs_Details {
font-size:10px;
color:#3F464C;
float:left;
position:relative;
bottom: -1px;
left: 3px;
}
.cs_AddLink {
font-size:10px;
float:left;
}
.cs_more {
font-size:10px;
float:right;
}
.cs_count {
font-size:10px;
color:#787878;
}
.cs_more_top {
font-size:10px;
float:right;
position:relative;
bottom: -1px;
right: 3px;
}
.cs_more_top img {
vertical-align: top;
padding-right: 5px;
}
.globe_green,
.globe_gray,
.globe_online,
.led_gray,
.led_green,
.led_red {
background-position:top center;
margin-top:3px;
}
.led_gray a:hover,
.led_green a:hover,
.led_red a:hover {
text-decoration: none;
}
.td_right {
text-align:right;
}
h4 a.head_link {
color: #3F464C;
float:left;
}
#tCalls a img {
border: none;
display:block;
}
span.limited {
display:inline-block;
vertical-align: top;
white-space:nowrap;
overflow:hidden;
text-overflow:ellipsis;
}
h4.homelua {
padding-bottom: 0;
}
tr h4.homelua {
margin-bottom: 0;
}
#tTab_Container2 {
margin-top: 8px;
}
th.home_head {
background-color: #f2f0ea;
height: 21px;
font-size: 12px;
font-weight: bold;
border-bottom: 1px solid #ffffff;
}
th.home_head span {
display: inline-block;
padding: 0 3px;
}
th.home_head span.head_link {
}
th.home_head span.head_link a {
color: #3F464C;
}
th.home_head span.details {
font-size: 11px;
font-weight: normal;
color: #3F464C;
}
th.home_head span.more_link {
float: right;
font-size: 11px;
font-weight: normal;
border-left: 1px solid #c6c7be;
padding-top:1px;
}
th.home_head span.icon_head {
float: right;
border-left: 1px solid #c6c7be;
width: 27px;
line-height: 0;
}
</style>
<!--[if lte IE 7]>
<style type="text/css">
th.home_head span {
float: left;
}
</style>
<![endif]-->
<?include "templates/page_head.html" ?>
<?lua
box.out([[<div id="uiViewHomeDiv" class="overview_tabs">]]..create_page_content()..[[</div>]])
?>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
function fbosPopup(href) {
var url = encodeURI(href);
var opts = "width=600,height=600,resizable=yes,scrollbars=yes,location=no";
var ppWindow = window.open(url, "Zweitfenster", opts);
if (ppWindow) {
ppWindow.focus();
}
}
function uiDoEjectUsb()
{
var txt = '{?537:669?}'
if ("<?lua box.js(g_coninf_data.webdav_enabled) ?>" == "1")
txt = '{?537:46?}'
if (confirm(txt))
return true;
return false;
}
function GotoInetstat(ziel)
{
jslSetValue("uiPostTab", ziel);
jslEnable("uiPostTab");
jslGoTo('internet','inetstat')
}
var json = makeJSONParser();
var url = encodeURI("/home/home.lua");
var _timer;
var g_NumberToDial=""
function callback_dial(response)
{
if (response && response.status == 200)
{
var resp = json(response.responseText || "null");
if (resp)
{
if (resp.dialing=="hangup")
{
alert("{?537:33?}");
}
else if (resp.dialing!="")
{
var g_txtMld1 = "{?537:917?}";
var g_txtMld2 = "{?537:7467?}";
var g_txtMld3 = "{?537:955?}";
var mld = jxl.sprintf(g_txtMld1, resp.dialing)+"\x0A\x0A"+
jxl.sprintf(g_txtMld2, resp.dialingport)+
"\x0A\x0A"+g_txtMld3;
if (!confirm(mld)) {
doRequest('dial','hangup');
}
}
}
}
}
function doRequest(info,addParam)
{
var urlPlus = url + "?" + buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
urlPlus += "&" + buildUrlParam("query", info);
var func=0;
switch(info)
{
case 'hangup' :func=callback_dial;break;
case 'dial' :
if (addParam)
{
if (addParam=="hangup")
{
urlPlus += "&" + buildUrlParam("action", "hangup");
}
else
{
urlPlus += "&" + buildUrlParam("action", "dial");
urlPlus += "&" + buildUrlParam("number", addParam);
}
}
func=callback_dial;
break;
}
ajaxGet(urlPlus, func);
}
var gComfort = "<?lua if g_show_full_comfort then box.js('1') else box.js('0') end ?>";
function set_Comfort()
{
jxl.disableNode("uiViewComfortLink", true);
jxl.disableNode("uiViewComfortLinkx", true);
if (gComfort=="1")
gComfort = "0";
else
gComfort = "1";
doRequestRefreshPage();
}
function cbRefreshPage(response)
{
if (response && response.status == 200)
{
if (response.responseText != "")
{
jxl.setHtml("uiViewHomeDiv", response.responseText);
}
}
}
function doRequestRefreshPage()
{
var my_url = "/home/home.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&comfort="+gComfort;
ajaxGet(my_url, cbRefreshPage);
}
function cbRefreshPageAuto(response)
{
cbRefreshPage(response);
window.setTimeout("doAutoRequestRefreshPage()", 20000);
}
function doAutoRequestRefreshPage()
{
var my_url = "/home/home.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&comfort="+gComfort;
ajaxGet(my_url, cbRefreshPageAuto);
}
function init()
{
window.setTimeout("doAutoRequestRefreshPage()", 20000);
}
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
