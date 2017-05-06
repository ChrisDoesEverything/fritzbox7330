<?lua
g_page_type = "all"
g_page_title = "{?865:695?}"
dofile("../templates/global_lua.lua")
require("string_op")
require"general"
g_wds_mode = ""
g_double_monitor=false
g_mac_24 = box.query("wlan:settings/wlanmac_ap")
g_mac_5 = ""
g_sz_mac_desc="{?865:368?}"
if config.WLAN.is_double_wlan then
g_double_monitor=true
g_mac_5 = box.query("wlan:settings/wlanmac_ap_scnd")
end
g_channel_5 = "0"
g_channel_24 = ""
g_SecLevel = ""
g_SecKey = ""
g_ipaddr = ""
g_netmask = ""
if (box.get) then
g_wds_mode = box.tohtml(box.get.wds_mode)
g_channel_5 = box.tohtml(box.get.channel5)
g_channel_24 = box.tohtml(box.get.channel24)
g_SecLevel = box.tohtml(box.get.seclevel)
g_SecKey = string_op.shift_blanks(box.tohtml(box.get.seckey))
g_ipaddr = box.tohtml(box.get.ipaddr)
g_netmask = box.tohtml(box.get.netmask)
end
if (g_wds_mode=="repeater") then
g_sz_mac_desc="{?865:563?}"
end
function get_overview()
local str=[[<p>]]
if (g_wds_mode=="repeater") then
str=str..[[{?865:13?}]]
else
str=str..[[{?865:817?}]]
end
str=str..[[</p><table class="zebra">]]
str=str..[[<tr><td>{?865:613?}:</td><td>]]
if (g_wds_mode=="repeater") then
str=str..[[{?865:115?}]]
else
str=str..[[{?865:708?}]]
end
str=str..[[</tr><tr>]]
if (g_double_monitor) then
str=str..[[<td nowrap>]]..g_sz_mac_desc..[[ (2,4 GHz):</td><td>]]..g_mac_24..[[</td></tr>]]
str=str..[[<tr><td nowrap>]]..g_sz_mac_desc..[[ (5 GHz):</td><td>]]..g_mac_5..[[</td>]]
else
str=str..[[<td>]]..g_sz_mac_desc..[[:</td><td>]]..g_mac_24..[[</td>]]
end
local sz_channel=[[{?865:964?}]]
str=str..[[</tr><tr><td>]]..sz_channel
if (g_double_monitor) then
str=str..[[ (2,4 GHz):</td><td>]]..g_channel_24..[[</td>]]
str=str..[[</tr><tr><td>]]..sz_channel..[[ (5 GHz):</td><td>]]..g_channel_5..[[</td>]]
else
str=str..[[:</td><td>]]..g_channel_24..[[</td>]]
end
local warn=""
if(g_SecLevel=="none") then
warn="WarnMsg"
end
str=str..[[</tr><tr class="]]..warn..[["><td>{?865:223?}:</td><td>]]
if (g_SecLevel=="wpa") then
str=str..[[WPA2]]
elseif(g_SecLevel=="wpa2") then
str=str..[[WPA2]]
elseif(g_SecLevel=="wep") then
str=str..[[WEP-128]]
elseif(g_SecLevel=="none") then
str=str..[[{?865:456?}]]
end
if (g_SecLevel~="none") then
str=str..[[</td></tr><tr><td>]]
if (g_SecLevel=="wpa" or g_SecLevel=="wpa2" ) then
str=str..[[{?865:973?}]]
else
str=str..[[{?865:47?}]]
end
str=str..[[:</td><td>]]..g_SecKey..[[</td></tr>]]
end
str=str..[[</td></tr></table>]]
if (g_wds_mode=="repeater") then
str=str..[[<p>{?865:448?}</p>]]
str=str..[[<table class="zebra"><tr>]]
str=str..[[<td>{?865:453?}:</td>]]
str=str..[[<td>]]..g_ipaddr..[[</td>]]
str=str..[[</tr><tr>]]
str=str..[[<td>{?865:353?}:</td>]]
str=str..[[<td>]]..g_netmask..[[</td>]]
str=str..[[</tr></table>]]
end
return str
end
?>
<?include "templates/html_head_popup.html" ?>
<style type="text/css">
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
<div class="formular">
<?lua box.out(get_overview()) ?>
<p>{?865:855?}</p>
</div>
</div>
</form>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
