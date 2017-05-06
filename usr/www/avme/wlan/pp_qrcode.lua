<?lua
g_page_type = "all"
g_page_title = box.tohtml(box.get.page_title)
dofile("../templates/global_lua.lua")
require"general"
g_no_auto_init_net_devices = true
require("net_devices")
g_data = {}
g_tab_options.notabs = true
function get_data(data_name)
if box.get[data_name] and box.get[data_name]~="" then
g_data[data_name] = box.get[data_name]
else
g_data[data_name] = box.query("wlan:settings/"..data_name)
end
end
if box.get.page_type and box.get.page_type ~= "" then
g_data.page_type = box.get.page_type
else
g_data.page_type = "main"
end
get_data("pskvalue")
get_data("encryption")
get_data("ssid")
get_data("bg_mode")
get_data("ap_enabled")
if config.WLAN.is_double_wlan then
get_data("ssid_scnd")
g_data.bg_mode_scnd = "52"
if config.WLAN.has_11ac then
get_data("bg_mode_scnd")
end
get_data("ap_enabled_scnd")
end
get_data("guest_ssid")
get_data("guest_encryption")
get_data("guest_pskvalue")
if box.get.wep_ascii_key and box.get.wep_ascii_key ~= "" then
g_data.wep_ascii_key = box.get.wep_ascii_key
else
get_data("key_id")
local wep_key_query = "key_value"..g_data.key_id
get_data(wep_key_query)
g_data.wep_hex_key = g_data[wep_key_query]
g_data.wep_ascii_key = net_devices.calc_ascii_key(g_data.wep_hex_key)
end
function double_wlan_ssids_different()
if config.WLAN.is_double_wlan and g_data.ssid_scnd and g_data.ssid_scnd ~= "" and g_data.ssid ~= g_data.ssid_scnd then
return true
end
return false
end
function get_as_table(str,block_size)
if not block_size or block_size<1 then
block_size=4
end
local t={}
local res=""
for i=1,#(str or ""),block_size do
res=string.sub(str,i,i+block_size-1)
table.insert(t,res)
end
return t
end
function write_pwd_row(pwd, split)
local pwd_str = ""
if (split) then
pwd=get_as_table(pwd,4)
for i,item in pairs (pwd) do
if (i % 2) == 0 then
pwd_str = pwd_str..[[&#8203;<span class="pwd_gray">]]..box.tohtml(item)..[[</span>]]
else
pwd_str = pwd_str..[[&#8203;<span>]]..box.tohtml(item)..[[</span>]]
end
end
else
pwd=get_as_table(pwd,4)
for i,item in pairs (pwd) do
pwd_str = pwd_str..[[&#8203;]]..box.tohtml(item)
end
end
box.out([[
<tr><td class="c1">]], box.tohtml([[{?573:290?}]]), [[</td>
<td class="c2">
<div class="light_gray">
<div class="pwd_block">
]], pwd_str, [[
</div>
</div>
</td>
</tr>]])
end
function get_wlan_standard_mode(bg_mode)
local standard = "{?573:700?}"
if bg_mode == "23" then
standard = '11n+11g'
elseif bg_mode == "24" then
standard = '11g+11b'
elseif bg_mode == "25" then
standard = '11n+11g+11b'
elseif bg_mode == "52" then
standard = '11a+11n'
elseif bg_mode == "53" then
standard = '11ac+11n'
end
return standard
end
function get_encryption_text(encryption)
if encryption=="0" then
return [[{?573:753?}]]
elseif encryption=="1" then
return [[{?573:237?}]]
elseif (encryption=="2") then
return [[{?573:642?}]]
elseif (encryption=="3") then
return [[{?573:391?}]]
elseif (encryption=="4") then
return [[{?573:135?}]]
end
end
function write_wlan_standard(bg_mode)
box.out([[
<tr><td class="c1">{?573:458?}</td>
<td class="c2"><div class="light_gray">]])
if double_wlan_ssids_different() then
box.out(get_wlan_standard_mode(bg_mode))
else
if g_data.ap_enabled == "1" then
box.out(get_wlan_standard_mode(bg_mode))
end
if g_data.ap_enabled_scnd and g_data.ap_enabled_scnd == "1" then
if g_data.ap_enabled == "1" then
box.html([[ (2,4 GHz) {?573:359?} ]])
end
if config.WLAN.has_11ac then
box.out(get_wlan_standard_mode(g_data.bg_mode_scnd))
else
box.out('11a+11n')
end
if g_data.ap_enabled == "1" then
box.html([[ (5 GHz)]])
end
end
end
box.out([[
</div></td></tr>]])
end
function write_main(id, ssid, bg_mode)
local box_name = box.query("box:settings/hostname")
if config.GUI_IS_REPEATER then
box_name = box.query("rext:settings/hostname")
end
if box_name~="" then
box_name = " / "..box.tohtml(box_name)
end
local hex_block = ""
box.out([[
<h4>]], general.sprintf([[{?573:394?}]], box.tohtml(config.PRODUKT_NAME)), box_name, [[</h4>
<p>{?573:602?}</p>
<table>
<tr><td class="c1">{?573:619?}</td><td class="c2"><div class="light_gray">]], box.tohtml(ssid), [[</div></td></tr>]])
write_wlan_standard(bg_mode)
if g_data.encryption=="0" then
write_pwd_row("")
elseif g_data.encryption=="1" then
write_pwd_row(g_data.wep_ascii_key)
else
require("val")
write_pwd_row(g_data.pskvalue, string.find(g_data.pskvalue, val.pr.decimals.pat))
end
box.out([[
<tr>
<td class="c1">{?573:603?}</td>
<td class="c2"><div class="light_gray">]], get_encryption_text(g_data.encryption), [[</div></td>
</tr>
<tr class="qrcode_block">
<td class="c1 small_font">]], general.sprintf([[{?573:937?}]], [[<a href="https://play.google.com/store/apps/details?id=de.avm.android.wlanapp" target="_blank">]],[[</a>]]), [[</td>
<td class="c2"><span id="]], id, [["></span></td>
</tr>
</table>
]])
end
function write_guest()
if box.query("wlan:settings/guest_ap_enabled") == "1" then
local guest_head_txt = [[{?573:430?}]]
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
guest_head_txt = [[{?573:545?}]]
else
guest_head_txt = [[{?573:587?}]]
end
end
box.out([[
<hr>
<h4>]], guest_head_txt, [[</h4>
<p>Für den Zugang ins Internet als Gast wird zur Anmeldung der Name des Funknetzes (SSID) und der WLAN-Netzwerkschlüssel benötigt. Die Nutzung kann protokolliert und auf bestimmte Internetanwendungen beschränkt werden.</p>
<table>
<tr><td class="c1">{?573:36?}</td><td class="c2"><div class="light_gray">]], box.tohtml(g_data.guest_ssid), [[</div></td></tr>]])
if g_data.guest_encryption ~= "0" then
write_pwd_row(g_data.guest_pskvalue)
end
box.out([[
<tr>
<td class="c1">{?573:5?}</td>
<td class="c2"><div class="light_gray">]], get_encryption_text(g_data.guest_encryption), [[</div></td>
</tr>
<tr class="qrcode_block">
<td class="c1 small_font">]], general.sprintf([[{?573:713?}]], [[<a href="https://play.google.com/store/apps/details?id=de.avm.android.wlanapp" target="_blank">]],[[</a>]]), [[</td>
<td class="c2"><span id="uiGuestQRCode"></span></td>
</tr>
</table>]])
end
end
function write_print_page(page_type)
if page_type == "guest" then
write_guest()
else
if double_wlan_ssids_different() then
if g_data.ap_enabled == "1" then
write_main("uiMainQRCode", g_data.ssid, g_data.bg_mode)
end
if g_data.ap_enabled_scnd == "1" then
write_main("uiMainQRCode_scnd", g_data.ssid_scnd, g_data.bg_mode_scnd)
end
else
write_main("uiMainQRCode", g_data.ssid, g_data.bg_mode)
end
end
end
?>
<?include "templates/html_head_popup.html" ?>
<style type="text/css">
.formular label {
margin-right: 6px;
width: 300px;
}
.pwd_block {
display:inline-block;
margin-left:-2px;
}
.pwd_block span {
padding-left:3px;
padding-right:3px;
}
.light_gray {
background-color:#e5e5e5;
padding:4px;
margin:2px;
}
.pwd_gray {
background-color:#d8d8d8;
padding:2px;
}
.small_font {
font-size:11px;
float:left;
width:300px;
}
tr.qrcode_block td{
padding-top:20px;
}
.qrcode_block span {
margin-left:10px;
}
h4 {
font-size:20px;
}
table {
background-color:transparent;
width:auto;
border:none;
}
table tr,td,th {
font-size:19px;
}
td.c2 {
width:60%;
}
td.c1 {
width:300px;
}
</style>
<script type="text/javascript" src="/js/qrcode.js"></script>
<script type="text/javascript">
function init()
{
<?lua
if g_data.page_type == "guest" then
local guest_key = g_data.guest_pskvalue
if g_data.guest_encryption == "0" then
guest_key = ""
end
box.out([[updateQRCode("uiGuestQRCode", "]], box.tojs(net_devices.get_wlan_qr_string(g_data.guest_ssid, g_data.guest_encryption, guest_key)), [[", 1.5);]])
else
local qr_key = g_data.pskvalue
if g_data.encryption=="0" then
qr_key = ""
elseif g_data.encryption=="1" then
qr_key = g_data.wep_ascii_key
end
box.out([[
if (]], box.tojs(double_wlan_ssids_different()), [[)
{]])
if g_data.ap_enabled == "1" then
box.out([[updateQRCode("uiMainQRCode", "]], box.tojs(net_devices.get_wlan_qr_string(g_data.ssid, g_data.encryption, qr_key)), [[", 0.7);]])
end
if g_data.ap_enabled_scnd == "1" then
box.out([[updateQRCode("uiMainQRCode_scnd", "]], box.tojs(net_devices.get_wlan_qr_string(g_data.ssid_scnd, g_data.encryption, qr_key)), [[", 0.7);]])
end
box.out([[
}
else
{
updateQRCode("uiMainQRCode", "]], box.tojs(net_devices.get_wlan_qr_string(g_data.ssid, g_data.encryption, qr_key)), [[", 1.5);
}
]])
end
?>
}
ready.onReady(init);
</script>
<?include "templates/page_head_popup.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" id="uiMainForm">
<div id="content">
<div class="formular">
<div class="formular small_indent">
<?lua box.out(write_print_page(g_data.page_type)) ?>
</div>
</div>
</div>
</form>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
