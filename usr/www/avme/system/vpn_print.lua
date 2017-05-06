<?lua
--[[
Datei Name:
Datei Beschreibung:
]]
g_page_type = "no_menu"
g_page_title = [[{?5510:76?}]]
dofile("../templates/global_lua.lua")
require("general")
g_var = {}
g_var.uid = box.get.uid
g_var.user_name = box.query("boxusers:settings/user["..g_var.uid.."]/name") or ""
g_var.vpn_psk = box.query("boxusers:settings/user["..g_var.uid.."]/vpn_psk") or ""
g_var.box_name = box.query("box:settings/hostname") or ""
g_var.type = "IPSec Xauth PSK"
g_var.server = ""
g_var.ddns_aktivated = box.query("ddns:settings/account0/activated") == "1"
if config.MYFRITZ then
local opmodes_to_lock = { opmode_usb_modem = true, opmode_eth_ipclient = true }
g_var.opmode = box.query("box:settings/opmode")
g_var.mf_enabled = box.query("jasonii:settings/enabled") == "1"
g_var.mf_state = tonumber(box.query("jasonii:settings/myfritzstate")) or 0
if not opmodes_to_lock[g_var.opmode] and g_var.mf_enabled and g_var.mf_state >= 300 then
g_var.server = box.query("jasonii:settings/dyndnsname") or ""
end
end
if g_var.ddns_aktivated and g_var.server == "" then
g_var.server = box.query("ddns:settings/account0/domain") or ""
end
if g_var.server == "" then
g_var.server = box.query("connection0:status/ip") or ""
g_var.dslite_active=false
if config.IPV6 and box.query("ipv6:settings/enabled") == "1" then
g_var.dslite_active = box.query("ipv6:settings/ipv4_active_mode") ~= "ipv4_normal"
if g_var.server == "" or g_var.dslite_active then
g_var.server = box.query("ipv6:settings/ip") or ""
end
end
end
?>
<?include "templates/html_head_popup.html" ?>
<style type="text/css">
.desc {
display: inline-block;
width: 160px;
}
.no_points {
list-style-type: none;
}
.courier {
font-family: Courier,serif, sans-serif, cursive;
}
</style>
<?include "templates/page_head_popup.html" ?>
<h4>{?5510:509?}</h4>
<p>
{?5510:636?}
</p>
<hr>
<h4>{?5510:317?}</h4>
<div class="formular">
<ul>
<li>{?5510:296?}</li>
<li>{?5510:218?}</li>
<li>{?5510:792?}</li>
<li>
{?5510:352?}
<br>
<ul class="no_points">
<li><span class="desc">{?5510:494?}</span><?lua box.html(g_var.box_name) ?></li>
<li><span class="desc">{?5510:189?}</span><?lua box.html(g_var.server) ?></li>
<li><span class="desc">{?5510:551?}</span><?lua box.html(g_var.user_name) ?></li>
<li><span class="desc">{?5510:8029?}</span><?lua box.out(general.sprintf([[{?5510:853?}]], box.tohtml(g_var.user_name))) ?></li>
<li>{?5510:350?}</li>
<li><span class="desc">{?5510:233?}</span><?lua box.html(g_var.user_name) ?></li>
<li><span class="desc">{?5510:51?}</span><span class="courier"><?lua box.html(g_var.vpn_psk) ?></span></li>
</ul>
</li>
<li>{?5510:471?}</li>
<li>{?5510:267?}</li>
</ul>
</div>
<hr>
<h4>{?5510:744?}</h4>
<div class="formular">
<div class="formular">
<h4>{?5510:248?}</h4>
</div>
<ul>
<li>{?5510:254?}</li>
<li>
{?5510:196?}
<br>
<ul class="no_points">
<li><span class="desc">{?5510:13?}</span><?lua box.html(g_var.box_name) ?></li>
<li><span class="desc">{?5510:772?}</span><?lua box.html(g_var.type) ?></li>
<li><span class="desc">{?5510:673?}</span><?lua box.html(g_var.server) ?></li>
<li><span class="desc">{?5510:278?}</span><?lua box.html(g_var.user_name) ?></li>
<li><span class="desc">{?5510:77?}</span><span class="courier"><?lua box.html(g_var.vpn_psk) ?></span></li>
</ul>
</li>
<li>{?5510:989?}</li>
</ul>
<div class="formular">
<h4>{?5510:457?}</h4>
<div>{?5510:240?}</div>
</div>
<ul class="no_points">
<li>
<ul class="no_points">
<li><span class="desc">{?5510:217?}</span><?lua box.html(g_var.user_name) ?></li>
<li><span class="desc">{?5510:538?}</span><?lua box.out(general.sprintf([[{?5510:912?}]], box.tohtml(g_var.user_name))) ?></li>
</ul>
</li>
</ul>
</div>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
