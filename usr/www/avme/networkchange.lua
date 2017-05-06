<?lua
--[[
Datei Name: /networkchange.lua
Datei Beschreibung:
]]
g_page_type = "no_menu"
g_page_title = [[{?9480:373?}]]
------------------------------------------------------------------------------------------------------------>
dofile("../templates/global_lua.lua")
require("general")
require("html")
g_ifmode=""
if (box.get and box.get["ifmode"]) then
g_ifmode=box.get["ifmode"]
end
g_NewIpAddr=""
if (box.get and box.get["newipaddr"]) then
g_NewIpAddr=box.get["newipaddr"]
end
function write_explain_txt()
if g_ifmode == "oma" then
html.p({},
[[{?9480:550?}]]
).write()
html.ul({style="font-size:inherit;"},
html.li({}, [[{?9480:832?}]]),
html.li({}, [[{?9480:835?}]])
).write()
html.p({},
html.raw(general.sprintf(
[[{?9480:36?}]],
html.strong({}, g_NewIpAddr).get()
))
).write()
return
end
if (g_ifmode=="dhcp") then
box.out([[{?9480:469?}<br><br>{?9480:537?}]])
return
end
box.out([[{?9480:27?}<br><br>]])
if g_ifmode=='static' then
box.out(general.sprintf([[{?9480:296?}]],box.tohtml(g_NewIpAddr)))
end
if g_ifmode=='modem' then
box.out(general.sprintf([[{?9480:768?}]],box.query("interfaces:settings/lan0/ipaddr")))
end
end
function write_destination()
local dest="/home/home.lua"
if g_ifmode=='static' or g_ifmode == 'oma' then
dest="http://"..g_NewIpAddr.."/"
end
if g_ifmode=='modem' then
dest="http://"..box.query("interfaces:settings/lan0/ipaddr").."/"
end
box.out(dest)
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var g_ifmode="<?lua box.js(g_ifmode)?>";
function doRedirectToStartpage()
{
top.location.href = "<?lua write_destination() ?>";
}
function init() {
if (g_ifmode == "oma") {
jxl.setHtml("forward",
"<p class=\"waitimg\"><img src=\"/css/default/images/wait.gif\"></p>");
}
else if (g_ifmode!="modem")
{
jxl.hide("btn_form_foot");
jxl.setHtml("forward",
"<p class=\"waitimg\"><img src=\"/css/default/images/wait.gif\"></p>"+
"<p>{?9480:431?}</p>");
ajaxWaitForBox();
}
else
{
jxl.setHtml("forward",
"<p class=\"waitimg\"><img src=\"/css/default/images/wait.gif\"></p>"+
"<p>{?9480:592?}</p>");
window.setTimeout("doRedirectToStartpage()", 15000);
}
}
window.onload = init;
</script>
<?include "templates/page_head.html" ?>
<p><?lua write_explain_txt() ?></p>
<div id="forward">
<p>{?9480:199?}</p>
</div>
<form action="<?lua write_destination()?>" method="GET">
<div id="btn_form_foot">
<button type="submit">{?txtToOverview?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
