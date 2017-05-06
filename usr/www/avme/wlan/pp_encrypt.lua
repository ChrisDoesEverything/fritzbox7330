<?lua
g_page_type = "all"
g_page_title = "{?7472:572?}"
dofile("../templates/global_lua.lua")
require"general"
require("string_op")
g_expertmode =(box.query("box:settings/expertmode/activated")=="1")
g_double_monitor=false
if config.WLAN.is_double_wlan then
g_double_monitor=true
end
g_SecLevel = ""
g_SecKey = ""
if (box.get) then
g_SecLevel = box.tohtml(box.get.seclevel)
g_wpakey = string_op.shift_blanks(box.tohtml(box.get.wpakey))
g_wepkey = string_op.shift_blanks(box.tohtml(box.get.wepkey))
g_wep_type = box.tohtml(box.get.weptype)
g_wephexkey1 = box.tohtml(box.get.wephexkey1)
g_wephexkey2 = box.tohtml(box.get.wephexkey2)
g_wephexkey3 = box.tohtml(box.get.wephexkey3)
g_wephexkey4 = box.tohtml(box.get.wephexkey4)
g_wepshared = box.tohtml(box.get.wepshared)
end
function get_seclevel()
local seclevel=g_SecLevel
local none="{?7472:842?}"
if (seclevel=="none") then
return none
elseif (seclevel=="wep") then
if (g_wep_type=="64") then
return "WEP-64"
end
return "WEP-128"
elseif (seclevel=="wpa") then
return "WPA"
elseif (seclevel=="wpa2") then
return "WPA2"
elseif (seclevel=="wpamixed") then
return "WPA + WPA2"
end
return none
end
function get_wpa_info()
if (g_SecLevel=="none" or g_SecLevel=="wep") then
return ""
end
local str=""
str=str..[[<tr><td>{?7472:741?}:</td><td>]]..g_wpakey..[[</td></tr>]]
str=str..[[<tr><td>{?7472:180?}:</td><td>{?7472:938?}</td></tr>]]
str=str..[[<tr><td>{?7472:53?}:</td><td>]]
if g_SecLevel=="wpa" then
str=str..[[WPA-PSK]]
elseif g_SecLevel=="wpa2" then
str=str..[[WPA2-PSK]]
else
str=str..[[WPA-PSK, WPA2-PSK]]
end
str=str..[[</td></tr>]]
str=str..[[<tr><td>{?7472:192?}:</td><td>]]
if g_SecLevel=="wpa" then
str=str..[[TKIP]]
elseif g_SecLevel=="wpa2" then
str=str..[[AES-CCMP]]
else
str=str..[[TKIP, AES-CCMP]]
end
str=str..[[</td></tr>]]
str=str..[[</table>]]
return str
end
function get_colgroup()
if (g_double_monitor) then
return [[<colgroup><col width="230px"><col width="auto"></colgroup>]]
end
return [[<colgroup><col width="200px"><col width="auto"></colgroup>]]
end
function get_wep_info()
if (g_SecLevel~="wep") then
return ""
end
local str=""
if (not g_expertmode) then
str=str..[[<tr><td>{?7472:847?}:</td><td>]]..g_wepkey..[[</td></tr>]]
end
str=str..[[<tr><td>{?7472:514?}:</td><td>{?7472:631?}</td></tr>]]
str=str..[[<tr><td>{?7472:523?}:</td><td>]]
if (g_wepshared=="1") then
str=str..[[{?7472:518?}]]
else
str=str..[[{?7472:448?}]]
end
str=str..[[</td></tr>]]
str=str..[[</table>]]
if (not g_expertmode) then
str=str..[[<p>{?7472:717?}</p>]]
str=str..[[<table class="zebra">]]..get_colgroup()..[[<tr>]]
str=str..[[<td>{?7472:44?}</td>]]
str=str..[[<td>]]..g_wephexkey1..[[</td></tr></table>]]
else
str=str..[[<table class="zebra">]]..get_colgroup()
str=str..[[<tr><td>{?7472:476?}:</td><td>]]..g_wephexkey1..[[</td></tr>]]
str=str..[[<tr><td>{?7472:167?}:</td><td>]]..g_wephexkey2..[[</td></tr>]]
str=str..[[<tr><td>{?7472:241?}:</td><td>]]..g_wephexkey3..[[</td></tr>]]
str=str..[[<tr><td>{?7472:344?}:</td><td>]]..g_wephexkey4..[[</td></tr></table>]]
end
return str
end
function get_none_info()
if (g_SecLevel~="none") then
return ""
end
local str=""
str=str..[[<tr><td>{?7472:426?}:</td><td>{?7472:82?}</td></tr>]]
str=str..[[<tr><td>{?7472:740?}:</td><td>{?7472:654?}</td></tr>]]
str=str..[[</table>]]
return str
end
function get_overview()
local str=[[<p>]]
str=str..[[{?7472:71?}]]
str=str..[[</p><table class="zebra">]]..get_colgroup()..[[<tr>]]
local szSSID="{?7472:201?}"
if (g_double_monitor) then
str=str..[[<td nowrap>]]..szSSID..[[ (2,4 GHz):</td><td>]]..string_op.shift_blanks(box.tohtml(box.query("wlan:settings/ssid")))..[[</td></tr>]]
str=str..[[<tr><td nowrap>]]..szSSID..[[ (5 GHz):</td><td>]]..string_op.shift_blanks(box.tohtml(box.query("wlan:settings/ssid_scnd")))..[[</td>]]
else
str=str..[[<td>]]..szSSID..[[:</td><td>]]..string_op.shift_blanks(box.tohtml(box.query("wlan:settings/ssid")))..[[</td>]]
end
str=str..[[</tr><tr><td>{?7472:947?}:</td><td>]]..get_seclevel()..[[</td></tr>]]
str=str..get_wpa_info()
str=str..get_wep_info()
str=str..get_none_info()
return str
end
?>
<?include "templates/html_head_popup.html" ?>
<style type="text/css">
table.zebra, table.zebra_reverse {
table-layout:fixed;
}
table.zebra td{
overflow:hidden;
white-space:pre-wrap;
text-overflow: ellipsis;
-o-text-overflow: ellipsis;
}
</style>
<script type="text/javascript">
function init()
{
}
ready.onReady(init);
</script>
<?include "templates/page_head_popup.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" id="uiMainForm">
<div id="content">
<div>
<?lua box.out(get_overview()) ?>
<p>{?7472:42?}</p>
</div>
</div>
</form>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
