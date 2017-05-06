<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_system_energiemonitor.html'
dofile("../templates/global_lua.lua")
require("config")
require("menu")
require("general")
require("umts")
g_max_x = 200
function get_width(val)
if val == 0 or not val then return 0 end
if val == 100 then return g_max_x end
return math.ceil(val * g_max_x / 100)
end
function get_bar(val, class)
if (val==nil) then
return ""
end
local w = get_width(val)
local fill = g_max_x - w
local str
str = [[<div class="meter">]]
if w > 0 then
str = str .. [[<div class="bar ]]..class..[[" style="width:]]..w..[[px"></div>]]
if fill > 0 then
str = str .. [[<div class="bar fill" style="width:]]..fill..[[px"></div>]]
end
else
str = str .. [[<div class="bar fillonly" style="width:]]..fill..[[px"></div>]]
end
str = str .. " "..val.." %</div>"
return str
end
function get_bars(part)
return get_bar(_G["g_"..part.."_act"], "act") .. get_bar(_G["g_"..part.."_cum"], "cum")
end
function write_bars(part)
box.out(get_bars(part))
end
g_sum_act = tonumber(box.query("power:status/rate_sumact"))
g_sum_cum = tonumber(box.query("power:status/rate_sumcum"))
g_up_minutes = tonumber(box.query("logic:status/uptime_minutes"))
g_up_hours = tonumber(box.query("logic:status/uptime_hours"))
g_up_days = math.floor(g_up_hours / 24);
g_up_hours = g_up_hours % 24;
if g_up_days == 0 then g_str_up_days = [[{?3947:609?}]]
elseif g_up_days == 1 then g_str_up_days = [[{?3947:122?}]]
else g_str_up_days = general.sprintf([[{?3947:491?}]], g_up_days)
end
if g_up_hours == 0 then g_str_up_hours = [[{?3947:959?}]]
elseif g_up_hours == 1 then g_str_up_hours = [[{?3947:364?}]]
else g_str_up_hours = general.sprintf([[{?3947:257?}]], g_up_hours)
end
if g_up_minutes == 0 then g_str_up_minutes = [[{?3947:902?}]]
elseif g_up_minutes == 1 then g_str_up_minutes = [[{?3947:871?}]]
else g_str_up_minutes = general.sprintf([[{?3947:465?}]], g_up_minutes)
end
g_str_uptime = general.sprintf([[{?3947:720?}]],
g_str_up_days, g_str_up_hours, g_str_up_minutes)
g_system_act = tonumber(box.query("power:status/rate_systemact"))
g_system_cum = tonumber(box.query("power:status/rate_systemcum"))
g_clock = nil
g_str_clock = ""
local state = box.query("power:status/system_status")
if state=="0" then g_clock = "125"
elseif state=="1" then g_clock = "150"
elseif state=="2" then g_clock = "62,5"
elseif state=="3" then g_clock = "120"
end
if g_clock then
g_str_clock = general.sprintf([[{?3947:603?}]], g_clock)
end
function umts_enabled()
if menu.check_page("internet","/internet/umts_settings.lua") then
return umts.enabled == "1"
end
return false
end
g_show_wlan = (config.WLAN_1350TNET and config.WLAN_TXPOWER) or config.WLAN_MADWIFI
if g_show_wlan then
g_wlan_act = tonumber(box.query("power:status/rate_wlanact"))
g_wlan_cum = tonumber(box.query("power:status/rate_wlancum"))
g_str_wlan_devs = ""
local ap_enabled=box.query("wlan:settings/ap_enabled")=="1"
if (not ap_enabled) then
ap_enabled=box.query("wlan:settings/ap_enabled_scnd")=="1"
end
if (ap_enabled) then
local devs = box.multiquery("wlan:settings/wlanlist/list(state)") or {}
local devcnt = 0
for _,t in ipairs(devs) do
if t[2]=="5" then devcnt = devcnt+1 end
end
green_ap_active = false
if config.WLAN.is_double_wlan then
if ((box.query("wlan:settings/green_ap_ps_active_2ghz") == "1") or (box.query("wlan:settings/green_ap_ps_active_5ghz") == "1")) then
green_ap_active = true
end
else
if (box.query("wlan:settings/green_ap_ps_active_2ghz") == "1") then
green_ap_active = true
end
end
if config.WLAN_GREEN then
if devcnt==0 and green_ap_active then
g_str_wlan_state = [[{?3947:80?}]]
else
g_str_wlan_state = [[{?3947:367?}]]
end
else
if config.WLAN.has_tx_autopower then
if box.query("wlan:settings/tx_autopower")=="1" then
g_str_wlan_state =[[{?3947:194?}]]
else
g_str_wlan_state = [[{?3947:264?}]]
end
else
g_str_wlan_state =[[]]
end
end
if devcnt == 0 then
g_str_wlan_devs = [[{?3947:629?}]]
elseif devcnt == 1 then
g_str_wlan_devs = [[{?3947:612?}]]
else
g_str_wlan_devs = general.sprintf([[{?3947:843?}]], devcnt)
end
else
g_str_wlan_state = [[{?3947:216?}]]
end
end
if config.LTE then
g_show_dsl=false
else
g_show_dsl = config.DSL
end
if g_show_dsl then
g_dsp_act = tonumber(box.query("power:status/rate_dspact"))
g_dsp_cum = tonumber(box.query("power:status/rate_dspcum"))
g_str_dsl_l2 = ""
if box.query("box:status/hint_dsl_no_cable")=="1" and not umts_enabled() then
g_str_dsl_state = [[{?3947:663?}]]
else
if general.is_atamode() or umts_enabled() then
g_str_dsl_state=[[{?3947:315?}]]
else
if box.query("connection0:status/connect")=="5" then
g_str_dsl_state = [[{?3947:9181?}]]
else
g_str_dsl_state = [[{?3947:479?}]]
end
g_str_dsl_l2 = [[{?3947:618?}]]
local adsl2_active=false
require("libluadsl")
local dsl_train_state = luadsl.getOverviewStatus(1,"DS").MODE
local l2_support = luadsl.getOverviewStatus(1,"DS").L2_SUPPORT
local l2_enable = luadsl.getOverviewStatus(1,"DS").L2_ENABLE
if (dsl_train_state == "ADSL2" or dsl_train_state == "ADSL2PLUS") then
adsl2_active=true
if l2_support then
if l2_enable then
g_str_dsl_l2 = [[{?3947:512?}]]
else
g_str_dsl_l2 = [[{?3947:563?}]]
end
end
end
end
end
end
g_show_ab = (config.AB_COUNT > 0)
if g_show_ab then
g_ab_act = tonumber(box.query("power:status/rate_abact"))
g_ab_cum = tonumber(box.query("power:status/rate_abcum"))
end
g_show_usb = config.USB_HOST or config.USB_HOST_AVM or config.USB_HOST_TI
if g_show_usb then
g_usb_act = tonumber(box.query("power:status/rate_usbhostact"))
g_usb_cum = tonumber(box.query("power:status/rate_usbhostcum"))
g_usb_count = tonumber(box.query("ctlusb:settings/device/count")) or 0
if g_usb_count < 1 then
g_str_usb = [[{?3947:330?}]]
elseif g_usb_count == 1 then
g_str_usb = [[{?3947:643?}]]
else
g_str_usb = general.sprintf([[{?3947:329?}]], g_usb_count)
end
end
g_show_lan = true
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/energy.css"/>
<!--[if lte IE 7]>
<link rel="stylesheet" type="text/css" href="/css/default/energy_ie.css"/>
<![endif]-->
<?include "templates/page_head.html" ?>
<p>{?3947:783?}</p>
<hr />
<table id="energy">
<tr>
<th id="desc">{?3947:7020?}</th>
<th class="legend">
<div class="bar act"></div> {?3947:436?}
<div class="bar cum seperated"></div> {?3947:350?}
</th>
<th id="detail">{?3947:584?}</th>
</tr>
<tr>
<td>{?3947:192?}</td>
<td><?lua write_bars("sum") ?></td>
<td><?lua box.html(g_str_uptime) ?></td>
</tr>
<tr>
<td>{?3947:493?}</td>
<td><?lua write_bars("system") ?></td>
<td><?lua box.html(g_str_clock) ?></td>
</tr>
<?lua
if g_show_wlan then
box.out([[
<tr>
<td>{?3947:751?}</td>
<td>]]..get_bars("wlan")..[[</td>
<td>]]..g_str_wlan_state..[[<br>]]..g_str_wlan_devs..[[</td>
</tr>
]])
end
if g_show_dsl then
box.out([[
<tr>
<td>{?3947:564?}</td>
<td>]]..get_bars("dsp")..[[</td>
<td>]]..g_str_dsl_state..[[<br>]]..g_str_dsl_l2..[[</td>
</tr>
]])
end
if g_show_ab then
if (config.AB_COUNT == 1) then
box.out([[
<tr>
<td>{?3947:622?}</td>
<td>]]..get_bars("ab")..[[</td>
<td></td>
</tr>
]])
else
box.out([[
<tr>
<td>{?3947:29?}</td>
<td>]]..get_bars("ab")..[[</td>
<td></td>
</tr>
]])
end
end
if g_show_usb then
box.out([[
<tr>
<td>{?3947:144?}</td>
<td>]]..get_bars("usb")..[[</td>
<td>]]..g_str_usb..[[</td>
</tr>
]])
end
if g_show_lan then
box.out([[
<tr>
<td>{?3947:399?}</td>
<td class="eth">]])
local conn = 0
for i=1,config.ETH_COUNT do
local img = "led_green.gif"
if box.query("eth"..tostring(i-1)..":status/carrier")=="0" then
img = "led_gray.gif"
else
conn = conn + 1
end
local txt = "LAN "..tostring(i)
if config.ETH_COUNT==1 then
txt = "LAN"
end
if i==1 then
box.out([[<img src="/css/default/images/]]..img..[[" class="led first"> ]]..txt)
else
box.out([[<img src="/css/default/images/]]..img..[[" class="led"> ]]..txt)
end
end
if config.ETH_COUNT==1 and box.query("eth0:settings/mode")=="0" then
g_str_lan = [[{?3947:186?}]]
else
g_str_lan = [[{?3947:535?}]]
end
if conn == 1 then
g_str_lan = [[{?3947:7444?}]]
elseif conn > 1 then
g_str_lan = general.sprintf([[{?3947:402?}]], conn)
end
box.out([[</td>
<td>]]..g_str_lan..[[</td>
</tr>
]])
end
?>
</table>
<form method="POST" action="/system/energy.lua">
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="reload">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
