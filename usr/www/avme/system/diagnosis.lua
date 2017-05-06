<?lua
g_page_type = "all"
g_page_title = [[{?520:76?}]]
g_page_help = 'hilfe_system_diagnose.html'
dofile("../templates/global_lua.lua")
require("general")
require("js")
g_start_text = [[{?520:341?}]]
g_stop_text = [[{?520:2857?}]]
local g_ajax = false
if box.get.useajax then
g_ajax = true
end
function remove_html(str)
str = str or ""
str = str:gsub([[(%<.-%>)]], [[ ]])
str = str:gsub([[&lt;]], [[<]])
str = str:gsub([[&gt;]], [[>]])
str = str:gsub([[&quot;]], [["]])
str = str:gsub([[&amp;]], [[&]])
str = str:gsub([=[[ ]+]=], [[ ]])
return str
end
function concatenate_text(text1, text2, text1_ex, text2_ex)
if not text1_ex then
text1_ex = "%1"
end
if not text2_ex then
text2_ex = "%1"
end
local text = ""
if text1 and text1 ~= "" and text2 and text2 ~= "" then
text = general.sprintf(text1_ex, text1)..[[, ]]..general.sprintf(text2_ex, text2)
elseif text2 and text2 ~= "" then
text = general.sprintf(text2_ex, text2)
elseif text1 and text1 ~= "" then
text = general.sprintf(text1_ex, text1)
end
return text
end
function get_fritz()
local diag = {}
diag.name = config.PRODUKT_NAME
diag.id = "uiFritz"
if g_ajax then
diag.status = "success"
local fname=box.query("box:settings/hostname")
local text = [[]]
if fname ~= "" then
text = fname..[[, ]]
end
text = text..box.query("logic:status/nspver")
diag.export = text
require"menu"
if menu.check_page("system", "/system/update.lua") then
text = text..[[, ]]
local update_state = box.query("updatecheck:status/state")
if box.query("box:status/signed_firmware") == "1" then
if box.query("updatecheck:status/update_available_hint") == "1" then
text = text..general.sprintf([[{?520:387?}]], [[<a href=']]..href.get("/system/update.lua")..[['>]], [[</a>]])
diag.status = "warning"
diag.export = [[{?520:253?}]]
else
text = text..[[{?520:401?}]]
diag.status = "success"
diag.export = text
end
else
local wrong_fw_text = [[{?520:631?}]]
diag.export = text..wrong_fw_text
text=text..[[<br>]]..wrong_fw_text..[[: ]]
text=text..[[ <a href="javascript:help.popup(']]..href.help_get("hilfe_nichtsigniert.html","hide=yes")..[[');">]]
text=text..box.tohtml([[{?520:675?}]])..[[.</a>]]
diag.status = "warning"
end
end
diag.text = text
end
return diag
end
function get_lan()
local diag = {}
diag.name = [[{?520:247?}]]
diag.id = "uiLan"
if g_ajax then
diag.status = "unknown"
local text = ""
local export_ports = ""
local green_ports = ""
local power_ports = ""
local conn = 0
for i=1,config.ETH_COUNT do
local img = "led_green.gif"
local txt = "LAN "..tostring(i)
if config.ETH_COUNT==1 then
txt = "LAN"
end
if box.query("eth"..tostring(i-1)..":status/carrier")=="0" then
img = "led_gray.gif"
else
conn = conn + 1
export_ports = concatenate_text(export_ports, txt)
end
if i==1 then
text = text..[[<img src="/css/default/images/]]..img..[[" class="led first"> ]]..txt
else
text = text..[[<img src="/css/default/images/]]..img..[[" class="led"> ]]..txt
end
if box.query("eth"..tostring(i - 1)..":settings/mode") == "2" then
power_ports = concatenate_text(power_ports, txt)
else
green_ports = concatenate_text(green_ports, txt)
end
end
local mode_text = concatenate_text(power_ports, green_ports, [[{?520:953?}]], [[{?520:726?}]])
if conn > 0 then
diag.export = general.sprintf([[{?520:647?}]], export_ports, mode_text)
else
diag.export = [[{?520:4523?}]]
end
diag.status = "success"
if config.ETH_COUNT==1 and box.query("eth0:settings/mode")=="0" then
local deaktivated_txt = [[{?520:750?}]]
diag.text = concatenate_text(deaktivated_txt, [[<span class="padding_left">]]..mode_text..[[</span>]])
diag.export = concatenate_text(deaktivated_txt, mode_text)
diag.status = "error"
else
diag.text = concatenate_text(text, [[<span class="padding_left">]]..mode_text..[[</span>]])
end
end
return diag
end
function get_ssid_text(ap_enabled, ssid)
local text = ""
if ap_enabled then
text = general.sprintf([[{?520:621?}]], ssid)
else
text = general.sprintf([[{?520:423?}]], ssid)
end
return text
end
function get_ap_text(wlan_list, ap_enabled, ap_conn_func, encryption_enabled, freq)
local text = ""
if ap_enabled then
local wlan_count = 0
for i, elem in pairs(wlan_list) do
if elem.state == "5" and ap_conn_func(elem)then
wlan_count = wlan_count + 1
end
end
text = text..[[, ]]
if wlan_count == 1 then
text = text..[[{?520:364?}]]
elseif wlan_count > 1 then
text = text..general.sprintf([[{?520:546?}]], wlan_count)
else
text = text..[[{?520:167?}]]
end
if not encryption_enabled then
text = text..[[, {?520:282?}]]
else
text = text..[[, {?520:578?}]]
end
status = "warning"
if box.query("wlan:settings/APEnvStatus") == "3" then
if freq == "5" or not config.WLAN.is_double_wlan then
text = [[{?520:406?}]]
end
elseif box.query("wlan:settings/APEnvStatus") == "1" then
text = [[{?520:909?}]]
end
end
return text
end
function get_wlan()
local diag = {}
diag.name = [[{?520:526?}]]
diag.id = "uiWLan"
if g_ajax then
require("bit")
diag.status = "success"
local ap_enabled = box.query("wlan:settings/ap_enabled")
local ssid = box.query("wlan:settings/ssid")
local ap_conn_func = function (elem) if not bit.isset(elem.mode,0) and not bit.isset(elem.mode,4) then return true end return false end
local wlan_enabled = false
diag.text = ""
diag.export = ""
local ap_text, ap_export = "", ""
local encryption_enabled = box.query("wlan:settings/encryption") ~= "0"
require("net_devices")
local wlan_list = net_devices.g_WlanList
if config.WLAN.is_double_wlan then
local ap_enabled_scnd = box.query("wlan:settings/ap_enabled_scnd")
if ap_enabled == "1" then
wlan_enabled = true
diag.export = [[2,4 GHz:]]..get_ssid_text(ap_enabled == "1", ssid)
diag.text = [[<b>2,4 GHz:</b> ]]..get_ssid_text(ap_enabled == "1", box.tohtml(ssid))
ap_text = get_ap_text(wlan_list, ap_enabled == "1", ap_conn_func, encryption_enabled)
diag.export = diag.export..ap_text
diag.text = diag.text..ap_text..[[]]
end
if ap_enabled_scnd == "1" then
wlan_enabled = true
if diag.text ~= "" then
diag.text = diag.text..[[<br>]]
end
local ssid_scnd = box.query("wlan:settings/ssid_scnd")
local ap5_conn_func = function (elem) if bit.isset(elem.mode,0) or bit.isset(elem.mode,4) then return true end return false end
diag.export = concatenate_text(diag.export, [[5 GHz:]]..get_ssid_text(ap_enabled_scnd == "1", ssid_scnd))
diag.text = diag.text..[[<b>5 GHz:</b> ]]..get_ssid_text(ap_enabled_scnd == "1", box.tohtml(ssid_scnd))
ap_text = get_ap_text(wlan_list, ap_enabled_scnd == "1", ap5_conn_func, encryption_enabled, "5")
diag.export = diag.export .. ap_text
diag.text = diag.text .. ap_text..[[]]
end
else
if ap_enabled == "1" then
wlan_enabled = true
diag.export = get_ssid_text(ap_enabled == "1", ssid)
diag.text = get_ssid_text(ap_enabled == "1", box.tohtml(ssid))
ap_text = get_ap_text(wlan_list, ap_enabled == "1", ap_conn_func, encryption_enabled)
diag.export = diag.export .. ap_text
diag.text = diag.text .. ap_text
end
end
if wlan_enabled then
local ap_status = box.query("wlan:settings/APEnvStatus")
if not encryption_enabled or ap_status == "3" or ap_status == "1" then
diag.status = "warning"
end
else
diag.text = [[{?520:859?}]]
diag.export = diag.text
wlan_enabled = false
diag.status = "warning"
end
if box.query("wlan:settings/wlan_config_status") =="fail" then
diag.text = [[{?520:201?}]]
diag.export = diag.text
diag.status = "error"
end
end
return diag
end
function get_dect()
local diag = {}
diag.name = [[{?520:241?}]]
diag.id = "uiDect"
diag.link = href.get("/dect/dect_settings.lua")
if g_ajax then
diag.status = "unknown"
local text = [[{?520:237?}]]
local dect_enabled = box.query("dect:settings/enabled")
if (dect_enabled == "1") then
diag.status = "success"
require("fon_devices")
local count_dect = fon_devices.get_connected_handset_count()
if (count_dect == 0) then
diag.status = "warning"
text = [[{?520:40?}, {?520:622?}]]
elseif (count_dect == 1) then
text = [[{?520:109?}, {?520:955?}]]
else
text = [[{?520:857?}, ]]..count_dect..[[ {?520:496?}]]
end
else
diag.status = "warning"
end
diag.text = text
diag.export = diag.text
end
return diag
end
function get_usb()
local diag = {}
diag.name = [[{?520:897?}]]
diag.id = "uiUsb"
if g_ajax then
diag.status = "success"
local usb_devices = require("usb_devices")
local mem_count = usb_devices.get_usb_mem_devices_count()
local partition_count = usb_devices.get_usb_mem_devices_count(true)
if not usb_devices.aura_for_storage_aktiv() and (mem_count > 0 or partition_count > 0) then
if partition_count < 1 then
diag.text = general.sprintf([[{?520:264?}]], mem_count)
elseif partition_count == 1 then
diag.text = general.sprintf([[{?520:657?}]], mem_count)
else
diag.text = general.sprintf([[{?520:306?}]], mem_count, partition_count)
end
end
local printer_count = usb_devices.get_usb_printer_count()
if not usb_devices.aura_for_printer_aktiv() and printer_count > 0 then
local printer_txt = general.sprintf([[{?520:8291?}]], printer_count)
if mem_count > 0 then
printer_txt = general.sprintf([[ {?520:37?}]], printer_count)
end
diag.text = diag.text..printer_txt
end
diag.export = diag.text
local dev_count = usb_devices.get_total_usb_devices_count()
if dev_count > 0 then
if usb_devices.aura_for_printer_aktiv() or usb_devices.aura_for_storage_aktiv() then
local aura_dev_count = dev_count - mem_count - printer_count
if usb_devices.aura_for_printer_aktiv() and usb_devices.aura_for_storage_aktiv() then
aura_dev_count = dev_count
end
if aura_dev_count == 1 then
diag.export = concatenate_text(diag.export, [[{?520:2265?}]])
diag.text = concatenate_text(diag.text, general.sprintf([[{?520:436?}]], [[<a href=']]..href.get("/usb/usb_remote_settings.lua")..[['>]], [[</a>]]))
elseif aura_dev_count > 1 then
diag.export = concatenate_text(diag.export, [[{?520:224?}]])
diag.text = concatenate_text(diag.text, general.sprintf([[{?520:195?}]], aura_dev_count, [[<a href=']]..href.get("/usb/usb_remote_settings.lua")..[['>]], [[</a>]]))
end
end
else
diag.text = [[{?520:734?}]]
diag.export = diag.text
end
end
return diag
end
function get_internet_connection()
local diag = {}
diag.name = [[{?520:497?}]]
diag.id = "uiInternetConnection"
diag.invisible = {"uiInternetAccess"}
if g_ajax then
diag.status = ""
local state = ""
local connection = require("connection")
g_coninf_data = connection.get_conn_inf_part()
if not general.is_wdsrepeater() and g_coninf_data.opmode:find("opmode_eth_") == 1 then
local status = ""
_,_, status = get_internet_access_lan()
if status == "error" then
state = "0"
diag.invisible = nil
end
end
if state == "" then
state = connection.Ppp_Led()
end
if state == "1" then
diag.status = "success"
else
diag.status = "warning"
diag.invisible = nil
end
local internet_state = connection.Display_Internet(state, false, "home")
diag.text = [[<b>{?520:987?}:</b> ]]..internet_state..[[]]
diag.export = [[{?520:378?}: ]]..internet_state
local ipv6_state = connection.Ppp_Led_Ipv6()
if g_coninf_data.ipv6_enabled=="1" then
internet_state = connection.Display_Internet(ipv6_state, true, "home")
diag.export = concatenate_text(diag.export, [[{?520:73?}: ]]..internet_state)
diag.text = diag.text..[[<br>]]..[[<b>{?520:942?}:</b> ]]..internet_state..[[]]
end
diag.export = remove_html(diag.export)
end
return diag
end
function get_internet_access_docsis()
local name = [[{?520:263?}]]
local text = ""
local export = ""
local status = "success"
require("docsis")
local stage = tonumber(docsis.initStage) or -1
if stage >= 16 then --ready
local result = {}
local hsec = tonumber(docsis.dsTimeActive) or 0
require("date")
text = [[{?520:78?}]]
if config.oem ~= 'kdg' then
local cnt = docsis.ds_count or 0
if cnt == 1 then
text = text..[[, {?520:129?}]]
else
text = text..general.sprintf([[, {?520:555?}]], cnt)
end
cnt = docsis.us_count or 0
if cnt == 1 then
text = text..[[, {?520:164?}]]
else
text = text..general.sprintf([[, {?520:891?}]], cnt)
end
end
elseif stage >= 0 then --scanning
text = [[{?520:362?}]]
status = "warning"
else
text = [[{?520:54?}]]
status = "error"
end
export = text
return name, text, status, export
end
function get_internet_access_umts()
local name = [[{?520:430?}]]
local text = ""
local export = ""
local status = "error"
require("umts")
require("umts_html")
local state_text = ""
local connected = false
state_text, connected = umts_html.connect_state()
if connected then
status = "success"
text = " "..text..state_text
export = text
text = text..umts_html.quality_img().get()
local homezone_img = umts_html.homezone_img()
if homezone_img then
text = concatenate_text(text, homezone_img.get())
end
if (config.DSL or config.VDSL) and not general.is_atamode() and umts.backup_enable == "1" then
local backup_enable_text = [[, {?520:970?}]]
text = text..backup_enable_text
export = export..backup_enable_text
end
else
text = [[{?520:919?}, ]]
if umts.ModemPresent ~= "1" then
text = text..[[{?520:802?}]]
export = text
elseif not umts.sim_ok() then
text = text..[[{?520:375?}]]
export = text
elseif umts.pin_needed('PIN') or umts.pin_needed('PUK') then
local sim_text = [[{?520:517?}]]
text = text..[[<a href=']]..href.get("/internet/umts_settings.lua")..[['>]]..sim_text..[[</a>]]
export = text..sim_text
else
local sim_text = [[{?520:629?}]]
text = text..[[<a href=']]..href.get("/internet/umts_settings.lua")..[['>]]..sim_text..[[</a>]]
export = text..sim_text
end
end
return name, text, status, export
end
function get_internet_access_lte()
local name = [[{?520:918?}]]
local text = [[{?520:393?}, ]]
local export = ""
local status = "error"
require("lted")
if lted.connected() then
status = "success"
local ds = tonumber(lted.connection.lte_connrate_rx) or 0
local us = tonumber(lted.connection.lte_connrate_tx) or 0
local ds_str, us_str = general.build_ds_us_strings(ds, us, [[{?520:6165?}]], [[{?520:101?}]])
text = text..[[{?520:681?}, ]]..ds_str..[[/]]..us_str
export = text
elseif lted.waiting_for("pin") then
local pin_text = [[{?520:725?}]]
text = text..[[<a href=']]..href.get("/internet/lte_settings.lua")..[['>]]..pin_text..[[</a>]]
export = text..pin_text
elseif lted.waiting_for("puk") then
local puk_text = [[{?520:382?}]]
local puk_entry_txt = [[{?520:558?}]]
text = text..puk_text..[[<a href=']]..href.get("/internet/lte_settings.lua")..[['>]]..puk_entry_txt..[[</a>]]
export = text..puk_text..", "..puk_entry_txt
elseif lted.waiting_for("sim") then
local sim_text = [[{?520:521?}]]
text = text..[[<a href=']]..href.get("/internet/lte_settings.lua")..[['>]]..sim_text..[[</a>]]
export = text..sim_text
else
text = text..[[<a href=']]..href.get("/system/syslog.lua", "param=internet")..[['>{?520:312?}</a>]]
export = text
end
return name, text, status, export
end
function get_internet_access_lan()
local name = [[{?520:337?}]]
local text = ""
local export = ""
local status = "success"
if box.query("eth0:status/carrier") == "1" then
text = [[{?520:144?}]]
else
text = [[{?520:106?}]]
status = "error"
end
export = text
return name, text, status, export
end
function get_internet_access_wlan()
local name = [[{?520:542?}]]
local text = ""
local export = ""
local status = "success"
if box.query("connection0:status/connect") == "5" then
text = [[{?520:733?}]]
else
text = [[{?520:514?}]]
status = "error"
end
local ap_enabled = box.query("wlan:settings/ap_enabled") == "1"
local ap_enabled_scnd = false
if config.WLAN.is_double_wlan then
ap_enabled_scnd = box.query("wlan:settings/ap_enabled_scnd") == "1"
end
if not ap_enabled and not ap_enabled_scnd then
text = [[{?520:428?}]]
status = "error"
end
export = text
return name, text, status, export
end
function get_sync_cnt_lua(resync_tbl)
local resync_cnt = 0
if resync_tbl and type(resync_tbl) == "table" then
for i,elem in pairs(resync_tbl) do
resync_cnt = resync_cnt + (tonumber(elem[2]) or 0)
end
end
return resync_cnt
end
function get_internet_access_dsl()
local name = [[{?520:208?}]]
local text = ""
local export = ""
local status = "error"
local total_sync_cnt = 0
local day_resync_cnt = 0
require("libluadsl")
day_resync_cnt = get_sync_cnt_lua(luadsl.getLongTimeStats (1, "DS").DAY_PER_HOUR_STAT_RESYNC)
total_sync_cnt = get_sync_cnt_lua(luadsl.getLongTimeStats (1, "DS").WEEK_PER_HOUR_STAT_RESYNC)
local uptime = tonumber(box.query("logic:status/uptime_hours")) * 60 + tonumber(box.query("logic:status/uptime_minutes"))
local help_link = general.sprintf([[, {?520:342?}]], [[<span class="hintMsg">{?txtHinweis?}</span>]], [[<a href=']]..href.get("/internet/dsl_test.lua")..[['>]], [[</a>]])
local dsl_state = general.get_dsl_state()
if dsl_state =="SHOWTIME" then
text = [[{?520:213?}]]
local ds = tonumber(luadsl.getOverviewStatus(1,"DS").ACT_DATA_RATE_US) or 0
local us = tonumber(luadsl.getOverviewStatus(1,"DS").ACT_DATA_RATE_DS) or 0
local ds_str, us_str = general.build_ds_us_strings(ds, us, [[{?520:322?}]], [[{?520:853?}]])
text = text..[[, ]]..ds_str..[[/]]..us_str..[[, ]]
local stable_txt = [[{?520:238?}]]
local unstable_txt = [[{?520:353?}]]
if uptime <= 15 then
if total_sync_cnt > 2 then
status = "warning"
export = text..unstable_txt
text = text..unstable_txt..help_link
elseif total_sync_cnt <= 2 then
status = "success"
text = text..stable_txt
export = text
end
else
if day_resync_cnt > 2 then
status = "warning"
export = text..unstable_txt
text = text..unstable_txt..help_link
elseif day_resync_cnt <= 2 or total_sync_cnt <= 2 then
status = "success"
text = text..stable_txt
export = text
end
end
elseif dsl_state =="NO_CABLE" then
export = [[{?520:346?}]]
text = export .. help_link
elseif dsl_state =="YES_CABLE" or dsl_state=="INIT" or dsl_state=="IDLE" then
export = [[{?520:747?}]]
text = export .. help_link
else
export = [[{?520:508?}]]
text = export .. help_link
local connecting_text = [[{?520:332?}]]
local connecting_text_warning = [[{?520:8016?}]]
if uptime <= 15 then
if total_sync_cnt > 2 then
status = "warning"
text = connecting_text_warning..help_link
export = connecting_text_warning
elseif total_sync_cnt <= 2 then
status = "warning"
text = connecting_text
export = text
end
else
if total_sync_cnt > 0 and day_resync_cnt <= 2 then
status = "warning"
text = connecting_text
export = text
elseif day_resync_cnt > 2 then
status = "warning"
text = connecting_text_warning..help_link
export = connecting_text_warning
end
end
end
return name, text, status, export
end
function get_internet_access()
local diag = {}
diag.name = [[{?520:24?}]]
diag.status=""
diag.id = "uiInternetAccess"
if g_ajax then
diag.status = "success"
diag.export = ""
diag.text = ""
local opmode = box.query("box:settings/opmode")
if opmode == "opmode_wlan_ip" or general.is_wdsrepeater() then
diag.name, diag.text, diag.status, diag.export = get_internet_access_wlan()
elseif opmode:find("opmode_eth_") == 1 then
diag.name, diag.text, diag.status, diag.export = get_internet_access_lan()
elseif config.LTE then
diag.name, diag.text, diag.status, diag.export = get_internet_access_lte()
elseif config.DOCSIS then
diag.name, diag.text, diag.status, diag.export = get_internet_access_docsis()
elseif config.VDSL or config.DSL then
diag.name, diag.text, diag.status, diag.export = get_internet_access_dsl()
end
if config.USB_GSM then
require("umts")
if umts.enabled == "1" or diag.status == "error" and umts.backup_enable == "1" and box.query("gsm:settings/ModemPresent") == '1' then
diag.name, diag.text, diag.status, diag.export = get_internet_access_umts()
end
end
end
return diag
end
function syslog_link(str)
return '<a href="'..href.get('/system/syslog.lua', 'tab=telefon')..'">'..str..'</a>'
end
function get_numbers()
local diag = {}
diag.name = [[{?520:102?}]]
diag.id = "uiNumbers"
diag.status = ""
if g_ajax then
require("fon_numbers")
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
diag.status = "unknown"
diag.text = ""
if num_tab.number_count <= 0 then
diag.status = "success"
diag.text = box.tohtml(general.sprintf([[{?520:418?}]], general.Callnumber_string(0)))
diag.export = diag.text
elseif num_tab.activ_count == 0 and num_tab.number_count > 0 then
diag.status = "warning"
diag.text = box.tohtml(general.sprintf([[{?520:366?}]], general.Callnumber_string(0)))
diag.export = diag.text
elseif num_tab.activ_count <= 3 and num_tab.activ_not_registered_count == 0 then
diag.status = "success"
diag.text = box.tohtml(general.sprintf([[{?520:671?} ]], (num_tab.activ_count - num_tab.activ_not_registered_count), general.Callnumber_string(num_tab.activ_count - num_tab.activ_not_registered_count)))
diag.text = diag.text..box.tohtml(table.concat(active_registered_numbers, ", "))
diag.export = diag.text
elseif num_tab.activ_count > 3 and num_tab.activ_not_registered_count == 0 then
diag.status = "success"
local tmptxt=[[{?520:173?}]]
diag.text = box.tohtml(general.sprintf(tmptxt, num_tab.activ_count, general.Callnumber_string(num_tab.activ_count)))
diag.export = diag.text
elseif num_tab.activ_count == num_tab.activ_not_registered_count then
diag.status = "warning"
local tmptxt=[[{?520:795?}]]
local x=box.tohtml([[{?520:271?}]])
diag.text = general.sprintf(tmptxt, box.tohtml(num_tab.activ_count), box.tohtml(general.Callnumber_string(num_tab.activ_count)), syslog_link(x))
diag.export = general.sprintf(tmptxt, box.tohtml(num_tab.activ_count), box.tohtml(general.Callnumber_string(num_tab.activ_count)), x)
else
diag.status = "success"
local tmptxt=[[{?520:595?}]]
diag.text = general.sprintf(tmptxt, box.tohtml(num_tab.activ_count), box.tohtml(general.Callnumber_string(num_tab.activ_count)), syslog_link(box.tohtml(tostring(num_tab.activ_not_registered_count))))
diag.export = general.sprintf(tmptxt, box.tohtml(num_tab.activ_count), box.tohtml(general.Callnumber_string(num_tab.activ_count)), box.tohtml(tostring(num_tab.activ_not_registered_count)))
if num_tab.activ_not_registered_count <= 2 then
diag.text = diag.text ..': '
diag.text = diag.text ..box.tohtml(table.concat(active_not_registered_numbers, ", "))
diag.export = diag.export..': '..box.tohtml(table.concat(active_not_registered_numbers, ", "))
end
end
end
return diag
end
function get_popup(title, content)
return [[
<div>
<div class="blue_bar_back" id="contentTitle">
<h2>]]..title..[[</h2>
</div>
<div class="page_content" id="page_content">
]]..content..[[
</div>
<div class="clear_float"></div>
</div>
]]
end
function get_out_num_request(param)
if (box.get.index=="dial") then
return [[stopXhr(gXhr); doRequest('dial', ]]..param..[[);]]
end
return [[stopXhr(gXhr); doRequest(]]..box.get.index..[[, ]]..param..[[);]]
end
local function show_nopassword()
local right_to_dial = tonumber(box.query("rights:status/Dial",0)) > 0
return not right_to_dial
end
function get_pretest_outgoing_calls()
local diag = {}
diag.name = [[{?520:663?}]]
diag.id = "uiOutgoingCalls"
diag.status = ""
diag.export = ""
if show_nopassword() then
local link = href.get("/system/boxuser_settings.lua", "back_to_page="..box.glob.script)
diag.text = [[{?520:718?}<br>]]..
general.sprintf([[{?520:276?}]],
[[<a href="]] .. box.tohtml(link) .. [[">]],
[[</a>]])
diag.export = [[{?520:229?}]]
elseif box.query("telcfg:settings/UseClickToDial") == "0" then
local link = href.get("/fon_num/dial_foncalls.lua", "back_to_page="..box.glob.script)
diag.export = [[{?520:389?}]]
diag.text = [[{?520:4921?}<br>]]..
general.sprintf([[{?520:422?}]],
[[<a href="]] .. box.tohtml(link) .. [[">]],
[[</a>]])
elseif g_ajax then
diag.status = "warning"
diag.text = "{?520:8?}"
diag.html = [[<b class="title">]]..box.tohtml(diag.name)..[[</b><br><a href="javascript:OnStartCall();">{?520:580?}</a>]]
diag.html_id=diag.id.."_1"
end
return diag
end
function get_outgoing_calls()
local diag = {}
diag.name = [[{?520:242?}]]
diag.id = "uiOutgoingCalls"
if g_ajax then
local validation = {
prog = [[
not_empty(uiOutNumber/number, wrong, error_num_txt)
char_range_regex(uiOutNumber/number, fonnumex, error_num_txt)
]]
}
box.post.number = box.get.number
require("val")
val.msg.error_num_txt = {
[val.ret.empty] = [[{?520:462?}]],
[val.ret.outofrange] = [[{?520:672?}]],
[val.ret.notfound] = [[{?520:9934?}]]
}
local valid = val.validate(validation) == val.ret.ok
local val_html_msg = ""
if box.get.number then
val_html_msg = val.get_html_msg(validation, "uiOutNumber")
end
local num_popup = get_popup(diag.name, [[
<p>{?520:854?}</p>
<p>{?520:484?}</p>
<div class="formular" >
<label for="uiOutNumber">{?520:744?}:</label>
<input type="text" id="uiOutNumber">]]..val_html_msg..[[
</div>
<div id="btn_form_foot" style="width: 500px;">
<button type="button" id="uiOutNrBtn" onclick="]]..get_out_num_request([['&abort=']])..[[ popup.close();">{?520:7?}</button>
<button type="button" id="uiOutNrBtn" onclick="]]..get_out_num_request([['&number='+jxl.getValue('uiOutNumber')]])..[[">{?520:791?}</button>
</div>
]])
local saveset = {}
if box.get.number then
diag.params = "&wait=wait"
if valid then
require("cmtable")
cmtable.add_var(saveset, "telcfg:command/Dial", tostring(box.get.number))
local err, msg = box.set_config(saveset)
diag.popup = get_popup(diag.name, [[
<p>{?520:94?}</p>
<p class="ClassHintsCentered">{?520:668?}</p>
<div id="btn_form_foot" style="width: 500px;">
<button type="button" onclick="]]..get_out_num_request([['&callfinished=success']])..[[ popup.close();">{?520:53?}</button>
<button type="button" onclick="]]..get_out_num_request([['&callfinished=']])..[[ popup.close();">{?520:386?}</button>
</div>
]])
else
diag.popup = num_popup
--diag.status = "warning"
--diag.text = ""
end
elseif box.get.callfinished then
if box.get.callfinished == "success" then
diag.params = "&result=success"
diag.status = "success"
diag.text = "{?520:571?}"
else
diag.params = "&result=error"
diag.status = "error"
diag.text = "{?520:901?}"
end
require("cmtable")
cmtable.add_var(saveset, "telcfg:command/Hangup", "")
local err, msg = box.set_config(saveset)
elseif box.get.abort then
diag.params = "&result=warning"
diag.status = "warning"
diag.text = "{?520:137?}"
else
if not box.get.wait then
diag.popup = num_popup
end
diag.params = "&wait=wait"
diag.text = "{?520:440?}"
end
diag.export = diag.text
end
return diag
end
function get_home_net()
local diag = {}
diag.name = [[{?520:724?}]]
diag.id = "uiHomeNet"
if g_ajax then
diag.status = "success"
require("net_devices")
local online_dev_count, dev_count = net_devices.get_online_dev_count()
if dev_count == 1 then
diag.text = general.sprintf([[{?520:5905?}]], dev_count, online_dev_count)
else
diag.text = general.sprintf([[{?520:934?}]], dev_count, online_dev_count)
end
local parental_control_abuse_count = net_devices.get_parental_control_abuse_count()
local add_link = ""
if parental_control_abuse_count > 0 then
diag.status = 'warning'
if parental_control_abuse_count == 1 then
diag.text = diag.text .. [[, {?520:762?}]]
else
diag.text = diag.text .. general.sprintf([[, {?520:678?}]], parental_control_abuse_count)
end
add_link = [[&nbsp;
<a href=" " onclick="showBlockedExplain(); return false;">
<img src="/css/default/images/icon_help.png" alt="" class="linkimg">
</a>
]]
end
diag.export = diag.text
diag.text = diag.text .. add_link
end
return diag
end
function get_wlan_env_text_status(freq, ssid, ap_enabled)
local status = "success"
require("wlanscan")
local num_of_aps = wlanscan.get_channel_usage_env_count(freq)
local ap_count_text = general.sprintf([[{?520:789?}]], num_of_aps)
if num_of_aps<0 then
num_of_aps=0
elseif num_of_aps == 1 then
ap_count_text = general.sprintf([[{?520:398?}]], num_of_aps)
end
local same_ssid_count = wlanscan.get_same_ssid_count(ssid)
local export = ""
local text = ""
if ap_enabled then
if same_ssid_count > 0 then
status = "warning"
text = ap_count_text
local same_text = [[{?520:945?}]]
if same_ssid_count == 1 then
same_text = [[{?520:455?}]]
end
export = text..[[, ]]..general.sprintf(same_text, same_ssid_count)
text = text..[[<br>]]..general.sprintf(same_text, same_ssid_count)
text = text..general.sprintf([[, {?520:6356?}]], [[<span class="hintMsg">{?txtHinweis?}</span>]], [[<a href=']]..href.get("/wlan/wlan_settings.lua")..[['>]], [[</a>]])
else
local no_net = [[{?520:145?}]]
text = ap_count_text
export = text..[[, ]]..no_net
text = text..[[<br>]]..no_net
end
if box.query("wlan:settings/APEnvStatus") == "3" then
status = "warning"
if freq == "5" or not config.WLAN.is_double_wlan then
text = [[{?520:594?}]]
export = [[{?520:116?}]]
end
elseif box.query("wlan:settings/APEnvStatus") == "1" then
text = [[{?520:669?}]]
status = "warning"
export = text
end
end
return text, status, export
end
function get_wlan_env()
local diag = {}
diag.name = [[{?520:200?}]]
diag.id = "uiWlanEnvNet"
if g_ajax then
diag.status = "success"
local same_ssid_count = 0
local ssid = box.query("wlan:settings/ssid")
local ap_enabled = box.query("wlan:settings/ap_enabled")
local wlan_enabled = false
local text = ""
local export = ""
local status = "success"
diag.text = ""
local inactive_text = [[{?520:191?}]]
if config.WLAN.is_double_wlan then
if ap_enabled == "1" then
wlan_enabled = true
text, status, export = get_wlan_env_text_status("24", ssid, ap_enabled == "1")
diag.status = status
diag.export = [[2,4 GHz: ]]..export
diag.text = [[<b>2,4 GHz:</b> ]]..text..[[]]
else
diag.export = [[2,4 GHz: ]]..inactive_text
diag.text = [[<b>2,4 GHz:</b> ]]..inactive_text
end
local ap_enabled_scnd = box.query("wlan:settings/ap_enabled_scnd")
if ap_enabled_scnd == "1" then
wlan_enabled = true
if diag.text ~= "" then
diag.text = diag.text..[[<br>]]
end
text, status, export = get_wlan_env_text_status("5", box.query("wlan:settings/ssid_scnd"), ap_enabled_scnd == "1")
diag.export = concatenate_text(diag.export, [[5 GHz: ]]..export)
diag.text = diag.text..[[<b>5 GHz:</b> ]]..text..[[]]
if diag.status == "success" then
diag.status = status
end
else
diag.export = diag.export..[[, 5 GHz: ]]..inactive_text
diag.text = diag.text.. [[<br><b>5 GHz:</b> ]]..inactive_text
end
else
if ap_enabled == "1" then
wlan_enabled = true
require("net_devices")
local bg_mode = tonumber(net_devices.get_bg_mode()) or 0
if bg_mode > 50 then
diag.text, diag.status, diag.export = get_wlan_env_text_status("5", ssid, ap_enabled == "1")
else
diag.text, diag.status, diag.export = get_wlan_env_text_status("24", ssid, ap_enabled == "1")
end
else
diag.export = inactive_text
diag.text = inactive_text
end
end
if box.query("wlan:settings/wlan_config_status") =="fail" then
diag.text = [[{?520:781?}]]
diag.export = diag.text
diag.status = "error"
end
end
return diag
end
g_diag_func = {}
g_diag = {}
function add_func(diag_func, condition)
if condition ~= false and diag_func then
if g_ajax then
table.insert(g_diag_func, diag_func)
elseif diag_func() then
table.insert(g_diag, diag_func())
end
end
end
add_func(get_fritz)
add_func(get_lan)
add_func(get_wlan, config.WLAN)
add_func(get_dect, config.DECT2)
add_func(get_usb, config.USB_STORAGE)
add_func(get_internet_connection)
add_func(get_internet_access)
add_func(get_numbers, config.FON)
--add_func(get_pretest_outgoing_calls, config.FON)
--add_func(get_outgoing_calls, config.FON)
add_func(get_home_net)
add_func(get_wlan_env, config.WLAN)
if g_ajax then
local index = tonumber(box.get.index)
local diag = {}
if index==nil then
if box.get.index=="dial" then
diag = get_outgoing_calls()
diag.index = index
end
else
if g_diag_func[index + 1] then
diag = g_diag_func[index + 1]()
diag.index = index
end
end
box.out(js.table(diag))
box.end_page()
end
function get_filename()
local t_current_date = os.date("*t");
require("date")
local l_sz_date = tostring(date.get_leading_zero(t_current_date.day))..[[.]]
l_sz_date = l_sz_date..tostring(date.get_leading_zero(t_current_date.month))..[[.]]
l_sz_date = l_sz_date..tostring(t_current_date.year)
l_sz_time = tostring(date.get_leading_zero(t_current_date.hour))..[[:]]
l_sz_time = l_sz_time..tostring(date.get_leading_zero(t_current_date.min))
local filename = config.PRODUKT_NAME.."_"..box.query("logic:status/nspver").."_"..l_sz_date.."_"..l_sz_time
return string.gsub(filename, "%s+", "_")
end
function write_csv(csv_text)
local sep = ";"
box.header(
"HTTP/1.0 200 OK\n"
.. "Content-Type: text/csv; charset=utf-8\n"
.. "Content-Disposition: attachment; filename="..get_filename().."-diagnose"..".csv\n\n"
)
box.out(string.char(0xEF)..string.char(0xBB)..string.char(0xBF))
box.out(csv_text)
box.end_page()
end
if box.post.csv then
write_csv(box.post.csv)
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<style type="text/css">
.waitimg {
width: 325px;
height: 5px;
}
table.zebra td {
padding-top: 4px;
padding-bottom: 4px;
padding-left: 10px;
}
img.led {
margin-left: 12px;
position: relative;
top: 3px;
}
img.first {
margin-left: 0;
}
.title {
font-size: 13px;
}
.padding_left {
padding-left: 10px;
}
.ClassHintsCentered
{
color:#0066CC;
text-align: center;
}
</style>
<?include "templates/page_head.html" ?>
<p>{?520:281?}</p>
<hr/>
<button type="button" id="uiStartStopBtn" onclick="doRequest()"><?lua box.out(g_start_text) ?></button>
<table id="uiDiagTable" class="zebra noborder">
</table>
<form method="POST" action="/system/diagnosis.lua">
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="post" id="uiExport" name="csv" onclick="jxl.setValue('uiExport', gCsv)" disabled>{?520:100?}</button>
<a href='<?lua box.html(href.get(box.glob.script, http.url_param("csv", ""))) ?>'>
</a>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/popup.js"></script>
<script type="text/javascript" src="/js/dialog.js"></script>
<script type="text/javascript">
var gDiag = <?lua box.out(js.table(g_diag)) ?>;
var gCall = <?lua box.out(js.table(get_outgoing_calls())) ?>;
var gInvisible = {};
var gCsv = "";
var gParams = "";
function init()
{
createTableRows();
updateZebra();
}
function getTitleElems(name)
{
var elems = ""
if (name && name != "")
{
elems = '<b class="title" >' + name + '</b><br>';
}
return elems;
}
function OnStartCall()
{
function find(idx)
{
var n = gDiag.length;
for (var i = 0; i < n; i++) {
if (gDiag[i].id==idx)
{
gDiag[i]=gCall
return gDiag[i];
}
}
return 0;
}
var diag=find("uiOutgoingCalls");
var tr = jxl.get(diag.id);
if (tr.hasChildNodes()) {
tr.children[0].innerHTML = '';
if (diag.name)
tr.children[1].innerHTML = getTitleElems(diag.name);
tr.children[1].innerHTML = tr.children[1].innerHTML + '<img class="waitimg" id="waitImg" src="/css/default/images/wait.gif">';
}
var my_url = "<?lua box.js(box.glob.script) ?>?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&index=dial";
gXhr = ajaxGet(my_url, cbRefreshPage);
}
function createTableRows()
{
var n = gDiag.length;
for (var i = 0; i < n; i++) {
var diag = gDiag[i];
var tr = document.createElement("tr");
tr.id = diag.id;
jxl.get("uiDiagTable").appendChild(tr);
updateRowContent(diag);
}
}
var gCurrentZebraClass = "zebraEven";
function switchZebra(tr)
{
if (tr.style.display != "none") {
if (gCurrentZebraClass == "zebraEven")
gCurrentZebraClass = "zebraOdd";
else
gCurrentZebraClass = "zebraEven";
}
tr.className = gCurrentZebraClass;
}
function updateZebra()
{
gCurrentZebraClass = "zebraEven";
jxl.walkDom("uiDiagTable", 'tr', switchZebra);
}
function updateVisiblity(id, oldTr)
{
var wasVisible = oldTr.style.display != "none";
if (gInvisible[id])
{
jxl.hide(id);
if (wasVisible)
updateZebra();
}
else
{
jxl.show(id);
if (!wasVisible)
updateZebra();
}
}
function updateRowContent(diag)
{
if (!diag)
return;
var row = jxl.get(diag.id);
var tr = row.cloneNode(false);
if (row.parentNode) {
row.parentNode.replaceChild(tr, row);
}
if (diag.invisible)
{
var n = diag.invisible.length;
for (var i = 0; i < n; i++) {
var invisibleElem = diag.invisible[i];
gInvisible[invisibleElem] = true;
}
}
updateVisiblity(diag.id, row)
var icon = "";
var text = "";
if (diag.status) {
icon = "icon_questionmark.gif";
switch(diag.status)
{
case 'success': gCsv += "{?520:51?}"; icon = "icon_success.png"; break;
case 'warning': gCsv += "{?520:534?}"; icon = "icon_warning.png"; break;
case 'error' : gCsv += "{?520:493?}"; icon = "error.png"; break;
}
}
gCsv += ";"
var iconTd = document.createElement("td");
jxl.addClass(iconTd, "iconrow");
if (icon && icon != "") {
var iconImg = document.createElement("img");
iconImg.src = "/css/default/images/" + icon
iconTd.appendChild(iconImg);
}
tr.appendChild(iconTd);
if (diag.name)
{
text = getTitleElems(diag.name);
gCsv += diag.name
}
gCsv += ";"
if (diag.text)
{
text = text + diag.text;
}
if (diag["export"])
{
gCsv += diag["export"]
}
gCsv += ";"
gCsv += "\r\n"
var textTd = document.createElement("td");
textTd.id=diag.id+"_1";
jxl.setHtml(textTd, text);
tr.appendChild(textTd);
}
function cbRefreshPage(response)
{
if (response && response.status == 200)
{
if (response.responseText != "")
{
var json = makeJSONParser();
try
{
var diag = json(response.responseText || "null");
}
catch(err)
{
}
if (diag)
{
updateRowContent(diag);
if (diag.index=="dial" && diag.params && diag.params != "")
doRequest(diag.index, diag.params);
else if (diag.params && diag.params != "" && !isNaN(Number(diag.index)) && Number(diag.index) < gDiag.length)
doRequest(diag.index, diag.params);
else if (!isNaN(Number(diag.index)) && Number(diag.index + 1) < gDiag.length)
doRequest(diag.index + 1);
else
stopRequest();
if (diag.html)
{
var elem=jxl.get(diag.html_id)
if (elem)
{
elem.innerHTML=diag.html;
}
}
//if (diag.popup && diag.params != "" && !isNaN(Number(diag.index)) && Number(diag.index) < gDiag.length)
if (diag.popup && diag.params != "" )
{
var popupElem = document.createElement("div");
popupElem.innerHTML = diag.popup;
jxl.addClass(popupElem, "popUpElem");
popup.updatePopup(popupElem, 523);
}
}
}
}
}
var gXhr;
function doRequest(index, params)
{
if (params && params != "")
gParams = "&" + params
if (!index)
{
gCsv = "";
index = 0;
gInvisible = {};
jxl.setText("uiStartStopBtn", "<?lua box.out(g_stop_text) ?>");
jxl.get("uiStartStopBtn").setAttribute('onclick', "stopRequest()");
jxl.disable("uiExport");
}
var diag = 0;
if (index=="dial")
diag=gCall;
else
diag = gDiag[index];
var tr = jxl.get(diag.id);
updateVisiblity(diag.id, tr);
if (gInvisible[diag.id])
{
doRequest(index + 1);
return;
}
if (tr.hasChildNodes()) {
tr.children[0].innerHTML = '';
if (diag.name)
tr.children[1].innerHTML = getTitleElems(diag.name);
tr.children[1].innerHTML = tr.children[1].innerHTML + '<img class="waitimg" id="waitImg" src="/css/default/images/wait.gif">';
}
var my_url = "<?lua box.js(box.glob.script) ?>?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&index="+index+gParams;
gParams = "";
gXhr = ajaxGet(my_url, cbRefreshPage);
}
function stopRequest()
{
stopXhr(gXhr);
jxl.setText("uiStartStopBtn", "<?lua box.out(g_start_text) ?>");
jxl.get("uiStartStopBtn").setAttribute('onclick', "doRequest()");
jxl.hide("waitImg");
jxl.enable("uiExport");
updateZebra();
}
ready.onReady(init);
function showBlockedExplain() {
var alertParams = {}
alertParams.Text1 = "{?520:3635?}";
alertParams.AddClass1 = "subtitle";
alertParams.Text2 = "\n\n";
alertParams.Text3 = "{?520:764?}";
alertParams.Text4 = "\n";
alertParams.Text5 = "{?520:512?}";
alertParams.Buttons = [{
txt: "{?520:457?}"
}];
dialog.messagebox(true, alertParams);
}
</script>
<?include "templates/html_end.html" ?>
