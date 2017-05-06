<?lua
g_page_type = "all"
g_page_title = "{?9876:698?}"
dofile("../templates/global_lua.lua")
require"general"
g_ipaddr = ""
g_netmask = ""
g_ip_start= ""
g_ip_end = ""
g_dhcp = ""
g_my_nat = ""
g_nat = ""
if (box.get) then
g_ipaddr = box.get.ipaddr
g_netmask = box.get.netmask
g_ip_start= box.get.ip_start
g_ip_end = box.get.ip_end
g_dhcp = box.get.use_dhcp
g_my_nat = box.get.my_nat
g_nat = box.get.nat
end
function get_overview()
local str=[[<p>{?9876:415?}</p>]]
str=str..[[<table class="zebra">]]
str=str..[[<tr><td>{?9876:836?}:</td><td>]]..box.tohtml(g_ipaddr)..[[</td></tr>]]
str=str..[[<tr><td>{?9876:143?}:</td><td>]]..box.tohtml(g_netmask)..[[</td></tr>]]
if g_dhcp=="1" then
str=str..[[<tr><td>{?9876:477?}:</td><td>{?9876:755?}</td></tr>]]
str=str..[[<tr><td>{?9876:36?}:</td><td>]]..box.tohtml(g_ip_start)..[[</td></tr>]]
str=str..[[<tr><td>{?9876:930?}:</td><td>]]..box.tohtml(g_ip_end)..[[</td></tr>]]
else
str=str..[[<tr><td>{?9876:295?}:</td><td>{?9876:138?}</td></tr>]]
end
if (g_my_nat=="1") then
str=str..[[<tr><td>{?9876:665?}:</td><td>]]
if (g_nat=="1") then
str=str..[[{?9876:40?}</td></tr>]]
else
str=str..[[{?9876:208?}</td></tr>]]
end
end
str=str..[[</table>]]
return str
end
?>
<?include "templates/html_head_popup.html" ?>
<style type="text/css">
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
<p>{?9876:507?}</p>
</div>
</div>
</form>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
